import Foundation
import CoreSession
import DashTypes
import Combine
import CoreKeychain
import CorePersonalData
import CoreNetworking
import CoreUserTracking
import SwiftTreats
import DashlaneAppKit
import LoginKit
import UIKit
import SwiftUI

class LocalLoginMigrationCoordinator: Coordinator, SubcoordinatorOwner {
    enum Completion {
        case session(Session)
        case logout
    }

    let navigator: Navigator
    let appServices: AppServicesContainer
    let localLoginHandler: LocalLoginHandler
    let logger: Logger
    let completion: @MainActor (Result<Completion, Error>) -> Void
    let mode: LocalLoginFlowViewModel.Completion.MigrationMode
    var sessionServicesSubscription: AnyCancellable?
    internal var subcoordinator: Coordinator?

    init(navigator: Navigator,
         appServices: AppServicesContainer,
         localLoginHandler: LocalLoginHandler,
         logger: Logger,
         mode: LocalLoginFlowViewModel.Completion.MigrationMode,
         completion: @escaping @MainActor (Result<Completion, Error>) -> Void) {
        self.navigator = navigator
        self.appServices = appServices
        self.mode = mode
        self.localLoginHandler = localLoginHandler
        self.logger = logger
        self.completion = completion
    }

    func start() {
        switch mode {
        case let .migrateAccount(migrationInfos, validator):
            migrate(with: migrationInfos, validator: validator)
        case let .migrateAnalyticsId(session):
            migrateAnalyticsId(for: session)
        case let .migrateSsoKey(type, email):
            migrateSSOKeys(with: type, email: email)
        }
    }

    private func migrate(with migrationInfos: AccountMigrationInfos,
                         validator: SSOLocalLoginValidator) {
        self.sessionServicesSubscription = SessionServicesContainer
            .buildSessionServices(from: migrationInfos.session,
                                  appServices: self.appServices,
                                  logger: self.logger,
                                  loadingContext: .remoteLogin) { [weak self] result in
                guard let self = self else { return }
                Task { @MainActor in
                    switch result {
                    case let .success(sessionServices):
                        switch migrationInfos.type {
                        case .ssoUserToMasterPasswordUser, .ssoUserToMasterPasswordAdmin:
                            self.startAccountMigration(for: .remoteKeyToMasterPassword(validator),
                                                       sessionServices: sessionServices,
                                                       authTicket: migrationInfos.authTicket)
                        case .masterPasswordUserToSSOUser:
                            self.startAccountMigration(for: .masterPasswordToRemoteKey(validator),
                                                       sessionServices: sessionServices,
                                                       authTicket: migrationInfos.authTicket)
                        }
                        sessionServices.activityReporter.logSuccessfulLoginWithSso()
                    case let .failure(error):
                        self.completion(.failure(error))
                    }
                }
            }
    }

    private func migrateSSOKeys(with type: SSOKeysMigrationType, email: String) {
        switch type {
        case let .localLogin(ssoKey, remoteKey):
            guard let oldSession = try? appServices.sessionContainer.loadSession(for: LoadSessionInformation(login: Login(email), masterKey: .ssoKey(remoteKey))) else {
                Task { @MainActor in
                    self.completion(.failure(AccountError.unknown))
                }
                return
            }

            migrate(oldSession, ssoKey: ssoKey, remoteKey: remoteKey)

        case let .unlock(oldSession, validator):
            if validator.isNitroProvider {
                let model = NitroSSOLoginViewModel(login: email, nitroWebService: appServices.nitroWebService) { [weak self] result in
                    self?.handleSSOResult(result, validator: validator, oldSession: oldSession)
                }
                let view = NitroSSOLoginView(model: model)
                navigator.present(UIHostingController(rootView: view), animated: true, completion: nil)
            } else {
                let model = SelfHostedSSOViewModel(login: email, authorisationURL: validator.serviceProviderUrl) { [weak self] result in
                    self?.handleSSOResult(result, validator: validator, oldSession: oldSession)
                }
                let view = SelfHostedSSOView(model: model)
                navigator.present(UIHostingController(rootView: view), animated: true, completion: nil)
            }
        }
    }

    private func handleSSOResult(_ result: Result<SSOCallbackInfos, Error>, validator: SSOValidator, oldSession: Session) {
        Task {
            do {
                let info = try result.get()
                let ssoKeys = try await validator.validateSSOTokenAndGetKeys(info.ssoToken,
                                                                             serviceProviderKey: info.serviceProviderKey)
                self.migrate(oldSession, ssoKey: ssoKeys.ssoKey, remoteKey: ssoKeys.remoteKey)
            } catch {
                await MainActor.run {
                    self.completion(.failure(error))
                }
            }
        }
    }

    private func migrate(_ session: Session, ssoKey: Data, remoteKey: Data) {
        do {
            let newSession = try appServices.sessionContainer.localMigration(of: session, ssoKey: ssoKey, remoteKey: remoteKey, config: appServices.sessionCryptoEngineProvider.defaultCryptoRawConfig(for: .ssoKey(ssoKey)))
            let masterKeyStatus = appServices.keychainService.masterKeyStatus(for: session.login)
            switch masterKeyStatus {
            case .available(accessMode: let accessMode):
                try? appServices.keychainService.save(newSession.configuration.masterKey.keyChainMasterKey,
                                                      for: session.login,
                                                      expiresAfter: AuthenticationKeychainService.defaultPasswordValidityPeriod,
                                                      accessMode: accessMode)
            case .expired, .notAvailable:
                break
            }
            localLoginHandler.finish(with: newSession)
            Task { @MainActor in
                self.completion(.success(.session(session)))
            }
        } catch {
            Task { @MainActor in
                completion(.failure(error))
            }
        }
    }

    private func migrateAnalyticsId(for session: Session) {
        let userAPIClient = appServices.appAPIClient.makeUserClient(sessionConfiguration: session.configuration)
        let client = AuthenticatedAccountAPIClient(apiClient: userAPIClient)
        client.accountInfo { result in
            Task { @MainActor in
                if let ids = try? result.get().analyticsIds {
                    let session = (try? self.appServices.sessionContainer.update(session, with: ids)) ?? session
                    self.completion(.success(.session(session)))
                } else {
                    self.completion(.success(.session(session)))
                }
            }
        }
    }
}

private extension LocalLoginMigrationCoordinator {
    func startAccountMigration(for type: MigrationType,
                               sessionServices: SessionServicesContainer,
                               authTicket: String?) {

        self.startSubcoordinator(AccountMigrationCoordinator(type: type,
                                                             navigator: navigator,
                                                             sessionServices: sessionServices,
                                                             authTicket: authTicket,
                                                             logger: logger) { [weak self] result in
            guard let self = self else {
                return
            }
            Task { @MainActor in
                switch result {
                case .success(.cancel):
                    self.completion(.success(.logout))
                case .success(.finished(let session)):
                    self.completion(.success(.session(session)))
                case .failure(let error):
                    self.completion(.failure(error))
                }
            }
        })
    }
}
