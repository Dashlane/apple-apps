import Combine
import CoreFeature
import CoreNetworking
import CorePremium
import CoreSession
import DashTypes
import DashlaneAPI
import Foundation
import LoginKit
import PremiumKit
import SwiftUI

extension LoginCoordinator {

  func loadSession(
    using remoteLoginSession: RemoteLoginSession,
    loadActionPublisher: PassthroughSubject<DeviceUnlinkLoadingAction, Never>,
    logInfo: LoginFlowLogInfo,
    remoteLoginHandler: RemoteLoginHandler
  ) {
    Task {
      do {
        let session = try await remoteLoginHandler.load(remoteLoginSession)
        self.appServices.loginMetricsReporter.refreshTimer(.login)
        sessionServicesSubscription =
          SessionServicesContainer
          .buildSessionServices(
            from: session,
            appServices: appServices,
            logger: sessionLogger,
            loadingContext: .remoteLogin(remoteLoginSession.isRecoveryLogin)
          ) { [weak self] result in
            guard let self = self else { return }
            loadActionPublisher.send(
              .finish {
                switch result {
                case let .success(sessionServices):
                  if remoteLoginSession.isRecoveryLogin,
                    let newMasterPassword = remoteLoginSession.newMasterPassword
                  {
                    self.changeMasterPassword(
                      sessionServices: sessionServices, newMasterPassword: newMasterPassword)
                  } else {
                    sessionServices.activityReporter.logSuccessfulLogin(
                      logInfo: logInfo,
                      isFirstLogin: true)
                    self.completion(.servicesLoaded(sessionServices))
                  }
                case let .failure(error):
                  self.handle(error: error)
                }
              })
          }
      } catch {
        self.handle(error: error)
      }
    }
  }
}

class PurchasePlanFlowProvider: LoginKit.PurchasePlanFlowProvider {
  let appServices: AppServicesContainer

  init(appServices: AppServicesContainer) {
    self.appServices = appServices
  }

  func makePurchasePlanFlow(
    for login: Login,
    authentication: ServerAuthentication,
    completion: @escaping (PurchasePlanFlowCompletion) -> Void
  ) async throws -> AnyView {
    let services = try await makePlanServices(for: login, authentication: authentication)
    return await PurchaseFlowView(model: .init(planPurchaseServices: services)) { action in
      switch action {
      case .cancellation, .failure:
        completion(.cancel)
      case .success:
        completion(.successful)
      }
    }.eraseToAnyView()
  }

  private func makePlanServices(
    for login: Login,
    authentication: ServerAuthentication
  ) async throws -> PlanPurchaseServicesContainer {
    let login = login

    let credentials = UserCredentials(
      login: login.email,
      deviceAccessKey: authentication.signedAuthentication.deviceAccessKey,
      deviceSecretKey: authentication.signedAuthentication.deviceSecretKey)
    let userDeviceAPIClient = appServices.appAPIClient.makeUserClient(credentials: credentials)

    let statusProvider = try await PremiumStatusAPIProvider(
      client: userDeviceAPIClient,
      logger: appServices.logger[.inAppPurchase])

    let purchaseService = try await PurchaseService(
      login: login,
      userDeviceAPIClient: userDeviceAPIClient,
      statusProvider: statusProvider,
      logger: appServices.rootLogger[.inAppPurchase])

    return PlanPurchaseServicesContainer(
      purchaseService: purchaseService,
      userDeviceAPIClient: userDeviceAPIClient,
      logger: appServices.rootLogger[.session],
      screenLocker: nil,
      activityReporter: appServices.activityReporter)
  }
}
