import Foundation
import CoreSession
import Combine
import CorePremium
import CoreNetworking
import CoreFeature
import LoginKit
import PremiumKit
import SwiftUI
import DashTypes

extension LoginCoordinator {

                func loadSession(using remoteLoginSession: RemoteLoginSession,
                     loadActionPublisher: PassthroughSubject<DeviceUnlinkLoadingAction, Never>,
                     logInfo: LoginFlowLogInfo,
                     remoteLoginHandler: RemoteLoginHandler) {
        Task {
            do {
                guard let session = try await remoteLoginHandler.load(remoteLoginSession, using: loginKitServices.remoteLoginInfoProvider, authTicket: nil) else {
                    return
                }
                self.appServices.loginMetricsReporter.refreshTimer(.login)
                sessionServicesSubscription = SessionServicesContainer
                    .buildSessionServices(from: session,
                                          appServices: appServices,
                                          logger: sessionLogger,
                                          loadingContext: .remoteLogin(remoteLoginSession.isRecoveryLogin)) { [weak self] result in
                        guard let self = self else { return }
                        loadActionPublisher.send(.finish {
                            switch result {
                            case let .success(sessionServices):
                                if remoteLoginSession.isRecoveryLogin, let newMasterPassword = remoteLoginSession.newMasterPassword {
                                    self.changeMasterPassword(sessionServices: sessionServices, newMasterPassword: newMasterPassword)
                                } else {
                                    sessionServices.activityReporter.logSuccessfulLogin(logInfo: logInfo,
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

class PurchasePlanFlowProvider: LoginKit.PurchasePlanFlowProvider, PremiumSessionDelegate {
    let appServices: AppServicesContainer

    init(appServices: AppServicesContainer) {
        self.appServices = appServices
    }

    func makePurchasePlanFlow(for login: Login,
                              authentication: ServerAuthentication,
                              completion: @escaping (PurchasePlanFlowCompletion) -> Void) -> AnyView {
        PurchaseFlowView(model: .init(planPurchaseServices: makePlanServices(for: login, authentication: authentication))) { action in
            switch action {
            case .cancellation, .failure:
                completion(.cancel)
            case .success:
                completion(.successful)
            }
        }.eraseToAnyView()
    }

    private func makePlanServices(for login: Login,
                                  authentication: ServerAuthentication) -> PlanPurchaseServicesContainer {
        let login = login
        let email = login.email
        let auth = authentication
        let ukiBasedWebService = LegacyWebServiceImpl()
        ukiBasedWebService.configureAuthentication(usingLogin: login.email, uki: auth.uki.rawValue)

        let dashlaneAPI = appServices.appAPIClient.makeUserClient(credentials: .init(login: login.email, deviceAccessKey: authentication.signedAuthentication.deviceAccessKey, deviceSecretKey: authentication.signedAuthentication.deviceSecretKey))
        let manager = DashlanePremiumManager.shared
        manager.endSession()

                try? manager.updateSessionWith(login: email,
                                       applicationUsernameHash: email.applicationUsernameHash(),
                                       webservice: ukiBasedWebService,
                                       dashlaneAPI: dashlaneAPI,
                                       delegate: self)

        return PlanPurchaseServicesContainer(manager: DashlanePremiumManager.shared,
                                             apiClient: dashlaneAPI,
                                             logger: appServices.rootLogger[.session],
                                             screenLocker: nil,
                                             activityReporter: appServices.activityReporter)
    }

    func premiumStatusData(for login: String) -> Data? {
        return nil
    }

    func setPremiumStatusData(_ data: Data?, for login: String) {}
}
