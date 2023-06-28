import Foundation
import CoreSession
import DashTypes
import CorePersonalData
import Combine
import AuthenticationServices
import CorePremium
import CoreUserTracking
import DashlaneCrypto
import SwiftTreats
import CoreSync
import LoginKit

extension AccountMigrationCoordinator {
            func createMasterPasswordChangerService(withNewMasterPassword newMasterPassword: String,
                                            sessionServices: SessionServicesContainer,
                                            newVerification: Verification?,
                                            authTicket: CoreSync.AuthTicket?,
                                            type: AccountMigrationType) async throws -> AccountCryptoChangerService {

        let masterPasswordBasedConfig = CryptoRawConfig.masterPasswordBasedDefault

        if type == .masterPasswordToMasterPassword {
            return try self.createMasterPasswordChangerService(withNewMasterPassword: newMasterPassword,
                                                               sessionServices: sessionServices,
                                                               newVerification: newVerification,
                                                               authTicket: authTicket,
                                                               type: type,
                                                               cryptoConfig: masterPasswordBasedConfig)
        } else {
            let cryptoUserPayload = try? await fetchTeamSpaceCryptoConfigHeader()
            let config = CryptoRawConfig(fixedSalt: masterPasswordBasedConfig.fixedSalt,
                                         userParametersHeader: masterPasswordBasedConfig.parametersHeader,
                                         teamSpaceParametersHeader: cryptoUserPayload)
            return try self.createMasterPasswordChangerService(withNewMasterPassword: newMasterPassword,
                                                               sessionServices: sessionServices,
                                                               newVerification: newVerification,
                                                               authTicket: authTicket,
                                                               type: type,
                                                               cryptoConfig: config)
        }
    }

        private func createMasterPasswordChangerService(withNewMasterPassword newMasterPassword: String,
                                                    sessionServices: SessionServicesContainer,
                                                    newVerification: Verification?,
                                                    authTicket: CoreSync.AuthTicket?,
                                                    type: AccountMigrationType,
                                                    cryptoConfig: CryptoRawConfig) throws -> AccountCryptoChangerService {

        let session = sessionServices.session
        let currentMasterKey = session.authenticationMethod.sessionKey

        let migratingSession = try sessionServices.appServices.sessionContainer.prepareMigration(of: session,
                                                                                                 to: .masterPassword(newMasterPassword, serverKey: currentMasterKey.serverKey), remoteKey: nil,
                                                                                                 cryptoConfig: cryptoConfig,
                                                                                                 accountMigrationType: type, loginOTPOption: type == .masterPasswordToMasterPassword ? session.configuration.info.loginOTPOption : nil)

        let postCryptoChangeHandler = PostMasterKeyChangerHandler(keychainService: sessionServices.appServices.keychainService,
                                                                  resetMasterPasswordService: sessionServices.resetMasterPasswordService,
                                                                  syncService: sessionServices.syncService)

        let reportedType: Definition.CryptoMigrationType = migratingSession.source.configuration.info.accountType == .sso ? .ssoToMasterPassword : .masterPasswordChange
        return try AccountCryptoChangerService(reportedType: reportedType,
                                               migratingSession: migratingSession,
                                               syncService: sessionServices.syncService,
                                               sessionCryptoUpdater: sessionServices.sessionCryptoUpdater,
                                               activityReporter: sessionServices.activityReporter,
                                               sessionsContainer: sessionServices.appServices.sessionContainer,
                                               databaseDriver: sessionServices.databaseDriver,
                                               postCryptoChangeHandler: postCryptoChangeHandler,
                                               apiNetworkingEngine: sessionServices.userDeviceAPIClient,
                                               authTicket: authTicket,
                                               logger: self.logger,
                                               cryptoSettings: cryptoConfig)

    }

        func createMasterPasswordChangerService(withServiceProviderKey serviceProviderKey: String,
                                            sessionServices: SessionServicesContainer,
                                            authTicket: String) throws -> AccountCryptoChangerService {

        let ssoServerKey = Random.randomData(ofSize: 64)
        let remoteKey = Random.randomData(ofSize: 64)
        guard let serviceProviderKeyData = Data(base64Encoded: serviceProviderKey) else {
            throw AccountError.unknown
        }

        let ssoKey = ssoServerKey ^ serviceProviderKeyData

        let session = sessionServices.session
        let config = sessionServices.appServices.sessionCryptoEngineProvider.defaultCryptoRawConfig(for: .ssoKey(ssoKey))
        let migratingSession = try sessionServices.appServices.sessionContainer.prepareMigration(of: session,
                                                                                                 to: .ssoKey(ssoKey),
                                                                                                 remoteKey: remoteKey,
                                                                                                 cryptoConfig: config,
                                                                                                 accountMigrationType: .masterPasswordToSSO,
                                                                                                 loginOTPOption: nil)
        let verification = Verification(type: .sso,
                                        ssoServerKey: ssoServerKey.base64EncodedString())

        let postCryptoChangeHandler = PostMasterKeyChangerHandler(keychainService: sessionServices.appServices.keychainService,
                                                                  resetMasterPasswordService: sessionServices.resetMasterPasswordService,
                                                                  syncService: sessionServices.syncService)

        return try AccountCryptoChangerService(reportedType: .masterPasswordToSso,
                                               migratingSession: migratingSession,
                                               syncService: sessionServices.syncService,
                                               sessionCryptoUpdater: sessionServices.sessionCryptoUpdater,
                                               activityReporter: sessionServices.activityReporter,
                                               sessionsContainer: sessionServices.appServices.sessionContainer,
                                               databaseDriver: sessionServices.databaseDriver,
                                               postCryptoChangeHandler: postCryptoChangeHandler,
                                               apiNetworkingEngine: sessionServices.userDeviceAPIClient,
                                               authTicket: AuthTicket(token: authTicket, verification: verification),
                                               logger: logger,
                                               cryptoSettings: migratingSession.target.cryptoConfig)
    }

    func fetchTeamSpaceCryptoConfigHeader() async throws -> CryptoEngineConfigHeader? {
        return try await withCheckedThrowingContinuation { continuation in
            let logger = self.logger
            PremiumStatusService(webservice: sessionServices.legacyWebService).getStatus { result in
                switch result {
                case let .success((status, _)):
                    let cryptoConfigFromTeamspace =  status.spaces?.first(where: { $0.status == .accepted })?.info.cryptoForcedPayload
                    logger.debug("Crypto from teamspace: \(String(describing: cryptoConfigFromTeamspace))")
                    continuation.resume(returning: cryptoConfigFromTeamspace)
                case .failure(let error):
                    logger.warning("Failed to load premium status configuration", error: error)
                   continuation.resume(throwing: error)
                }
            }
        }
    }

        func showSSOLogin(with validator: SSOValidator) {
        authenticate(with: validator) { result in
            switch result {
            case let  .success((authTicket, serviceProviderKey)):
                DispatchQueue.main.async {
                    self.startChangeMasterKey(withAuthTicket: authTicket, serviceProviderKey: serviceProviderKey)
                }
            case let .failure(error):
                self.completion(.failure(error))
            }
        }
    }

    func authenticate(with validator: SSOValidator, completion: @escaping CompletionBlock<(String, String), Swift.Error>) {
        if validator.isNitroProvider {
            let model = NitroSSOLoginViewModel(login: sessionServices.session.login.email, nitroWebService: sessionServices.appServices.nitroWebService) { result in
                self.handleSSOResult(result, validator: validator, completion: completion)
            }
            navigator.push(NitroSSOLoginView(model: model, clearCookies: true))
        } else {
            let model = SelfHostedSSOViewModel(login: sessionServices.session.login.email, authorisationURL: validator.serviceProviderUrl) { result in
                self.handleSSOResult(result, validator: validator, completion: completion)
            }
            navigator.push(SelfHostedSSOView(model: model, clearCookies: true))
        }
    }

        func handleSSOResult(_ result: Result<SSOCallbackInfos, Error>, validator: SSOValidator, completion: @escaping CompletionBlock<(String, String), Swift.Error>) {
        DispatchQueue.main.async {
            switch result {
            case let .success(callbackInfos):
                if let authTicket = self.authTicket {
                    completion(.success((authTicket, callbackInfos.serviceProviderKey)))
                } else {
                    self.validateSSOToken(validator: validator, callbackInfos: callbackInfos, completion: completion)
                }
            case let .failure(error):
                self.navigator.pop()
                completion(.failure(error))
            }
        }
    }

    private func validateSSOToken(validator: SSOValidator,
                                  callbackInfos: SSOCallbackInfos,
                                  completion: @escaping CompletionBlock<(String, String), Swift.Error>) {
        validator.authTicket(token: callbackInfos.ssoToken, login: self.sessionServices.session.login.email, completion: { result in
            switch result {
            case .success(let authTicket):
                completion(.success((authTicket, callbackInfos.serviceProviderKey)))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
}
