import Combine
import CoreFeature
import CoreNetworking
import CorePremium
import CoreSession
import CoreTypes
import DashlaneAPI
import Foundation
import LoginKit
import PremiumKit
import SwiftUI

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
      activityReporter: appServices.activityReporter,
      vaultStateService: nil,
      deeplinkingService: appServices.deepLinkingService,
      premiumStatusProvider: statusProvider)
  }
}
