import Foundation
import DashTypes
import SwiftTreats

@MainActor
public class LocalLoginHandler {

        public enum Step {
        case initialize
                case validateThirdPartyOTP(ThirdPartyOTPLocalLoginValidator)
                case migrateAccount(AccountMigrationInfos, SSOLocalLoginValidator)
        case unlock(UnlockSessionHandler, UnlockType)
        case migrateAnalyticsId(Session) 
                case migrateSSOKeys(SSOKeysMigrationType)
        case completed(Session)
    }

    public enum Error: Swift.Error {
        case wrongMasterKey
        case ssoLoginRequired
    }

    public internal(set) var step: Step = .initialize

    private let logger: Logger
    public let login: Login
    let sessionsContainer: SessionsContainerProtocol
    let accountAPIClient: AccountAPIClientProtocol
    let deviceId: String
    let workingQueue: DispatchQueue
    private let deviceInfo: DeviceInfo
    let context: LoginContext?
    var ssoInfo: SSOInfo?
    var loginMethod: LoginMethod?

    var deviceAccessKey: String {
        return info.deviceAccessKey ?? self.deviceId
    }

    private let info: SessionInfo
    let cryptoEngineProvider: CryptoEngineProvider

    init?(login: Login,
          deviceInfo: DeviceInfo,
          deviceId: String, 
          sessionsContainer: SessionsContainerProtocol,
          accountAPIClient: AccountAPIClientProtocol,
          context: LoginContext?,
          workingQueue: DispatchQueue = DispatchQueue.global(qos: .userInitiated),
          logger: Logger,
          cryptoEngineProvider: CryptoEngineProvider) {

        do {
            let info = try sessionsContainer.info(for: login)

            self.logger = logger
            self.login = login
            self.deviceInfo = deviceInfo
            self.info = info
            self.sessionsContainer = sessionsContainer
            self.accountAPIClient = accountAPIClient
            self.context = context
            self.deviceId = deviceId
            self.workingQueue = workingQueue
            self.cryptoEngineProvider = cryptoEngineProvider
        } catch {
            logger.error("Local Handler failed to init for login \(login)", error: error)
            return nil
        }
    }

    func configureFirstStep() async {
        if let option = self.info.loginOTPOption {
            let validator = ThirdPartyOTPLocalLoginValidator(login: self.login, deviceInfo: self.deviceInfo, deviceAccessKey: self.deviceAccessKey, option: option, accountAPIClient: self.accountAPIClient)
            validator.delegate = self
            self.step = .validateThirdPartyOTP(validator)
        }
        else if self.info.isPartOfSSOCompany {
                        do {
                let response = try await self.accountAPIClient.requestLogin(with: LoginRequestInfo(login: self.login.email, deviceAccessKey: self.deviceAccessKey, u2fSecret: nil, loginsToCheckForDeletion: [self.login]))
                self.loginMethod = response.loginMethod(for: self.login, with: self.context)
            } catch {}
            
            if case let .loginViaSSO(serviceProviderUrl, isNitroProvider) = self.loginMethod {
                let validator = SSOLocalLoginValidator(login: self.login, deviceAccessKey: self.deviceAccessKey, accountAPIClient: self.accountAPIClient, serviceProviderUrl: serviceProviderUrl, cryptoEngineProvider: self.cryptoEngineProvider, isNitroProvider: isNitroProvider)
                 self.moveToUnlockStep(with: .ssoValidation(validator))
            } else {
                 self.moveToUnlockStep(with: .mpValidation)
            }
        }
        else {
             self.moveToUnlockStep(with: .mpValidation)
        }
    }

    private func moveToUnlockStep(with type: UnlockType) {
        let passwordUnlocker = UnlockAndLoadLocalSession(localLoginHandler: self, type: type, logger: logger)
        step = .unlock(passwordUnlocker, type)
    }

    public func validateSSOKey(_ ssoKeys: SSOKeys, loginContext: LoginContext, validator: SSOLocalLoginValidator) async throws {
        let passwordUnlocker = UnlockAndLoadLocalSession(localLoginHandler: self, type: .ssoValidation(validator, authTicket: ssoKeys.authTicket, remoteKey: ssoKeys.remoteKey), logger: logger)
        try await passwordUnlocker.unlock(with: .ssoKey(ssoKeys.ssoKey), loginContext: loginContext)
    }

    public func finish(with session: Session) {
        step = .completed(session)
    }

    private func makeSSOLocalLoginValidator() -> SSOLocalLoginValidator? {
        if case let .loginViaSSO(serviceProviderUrl, isNitroProvider) = loginMethod {
            let validator = SSOLocalLoginValidator(login: self.login, deviceAccessKey: self.deviceAccessKey, accountAPIClient: self.accountAPIClient, serviceProviderUrl: serviceProviderUrl, cryptoEngineProvider: cryptoEngineProvider, isNitroProvider: isNitroProvider)
            return validator
        }
        return nil
    }
}

extension LocalLoginHandler: ThirdPartyOTPLocalLoginValidatorDelegate {
    public func thirdPartyOTPLocalLoginValidatorDidRetrieveServerKey(_ serverKey: String, authTicket: String?) async {
        moveToUnlockStep(with: .mpOtp2Validation(authTicket: authTicket, serverKey: serverKey))
    }
}

internal struct UnlockAndLoadLocalSession: UnlockSessionHandler {
    let localLoginHandler: LocalLoginHandler
    let type: UnlockType
    let logger: Logger
    
    func unlock(with masterKey: MasterKey,
                loginContext: LoginContext) async throws {
        var masterKey = masterKey
        if case let UnlockType.mpOtp2Validation(_, serverKey) = type {
            masterKey = masterKey.masterKey(withServerKey: serverKey)
        }
        let loadInfo = LoadSessionInformation(login: localLoginHandler.login,
                                              masterKey: masterKey)
        let logger = self.logger
        do {
            let session = try localLoginHandler.sessionsContainer.loadSession(for: loadInfo)
            logger.debug("Loaded local session with crypto")
            await MainActor.run {
                self.localLoginHandler.step = type.localLoginStep(with: localLoginHandler, session: session, context: loginContext, cryptoEngineProvider: localLoginHandler.cryptoEngineProvider)
            }
        } catch(SessionsContainerError.cannotDecypherLocalKey) {
            if let step = type.localLoginStep(with: masterKey) {
                await MainActor.run {
                    self.localLoginHandler.step = step
                }
            } else {
                throw LocalLoginHandler.Error.wrongMasterKey
            }
        }
    }
}

