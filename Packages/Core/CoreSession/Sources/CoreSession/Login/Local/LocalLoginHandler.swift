import Foundation
import DashTypes
import SwiftTreats
import DashlaneAPI

@MainActor
public class LocalLoginHandler {

        public enum Step {
        case initialize
                case validateThirdPartyOTP(ThirdPartyOTPOption)
                case migrateAccount(AccountMigrationInfos, SSOLocalLoginValidator)
        case unlock(UnlockSessionHandler, UnlockType)
        case migrateAnalyticsId(Session) 
                case migrateSSOKeys(SSOKeysMigrationType)
        case completed(Session, isRecoveryLogin: Bool)
    }

    public enum Error: Swift.Error {
        case wrongMasterKey
        case ssoLoginRequired
        case noServerKey
    }

    public internal(set) var step: Step = .initialize

    private let logger: Logger
    public let login: Login
    let sessionsContainer: SessionsContainerProtocol
    let appAPIClient: AppAPIClient
    let deviceId: String
    public let deviceInfo: DeviceInfo
    let context: LoginContext?
    var ssoInfo: SSOInfo?
    var loginMethod: LoginMethod?

    var deviceAccessKey: String {
        return info.deviceAccessKey ?? self.deviceId
    }

    private let info: SessionInfo
    let cryptoEngineProvider: CryptoEngineProvider

    public var accountType: AccountType {
        info.accountType
    }

    init?(login: Login,
          deviceInfo: DeviceInfo,
          deviceId: String, 
          sessionsContainer: SessionsContainerProtocol,
          appAPIClient: AppAPIClient,
          context: LoginContext?,
          logger: Logger,
          cryptoEngineProvider: CryptoEngineProvider) {

        do {
            let info = try sessionsContainer.info(for: login)
            self.logger = logger
            self.login = login
            self.deviceInfo = deviceInfo
            self.info = info
            self.sessionsContainer = sessionsContainer
            self.appAPIClient = appAPIClient
            self.context = context
            self.deviceId = deviceId
            self.cryptoEngineProvider = cryptoEngineProvider
        } catch {
            logger.error("Local Handler failed to init for login \(login)", error: error)
            return nil
        }
    }

    func configureFirstStep() async {
        if let option = self.info.loginOTPOption {
            self.step = .validateThirdPartyOTP(option)
        } else if self.info.accountType == .sso {
                        do {
                let response = try await self.appAPIClient.authentication.getAuthenticationMethodsForLogin(
                    login: self.login.email,
                    deviceAccessKey: self.deviceAccessKey,
                    methods: [.emailToken, .totp, .duoPush, .dashlaneAuthenticator],
                    profiles: [
                        AuthenticationGetMethodsForLoginProfiles(
                            login: self.login.email,
                            deviceAccessKey: deviceAccessKey
                        )
                    ],
                    u2fSecret: nil
                )
                self.loginMethod = response.verifications.loginMethod(for: self.login, with: self.context)
            } catch {}

            if case let .loginViaSSO(serviceProviderUrl, isNitroProvider) = self.loginMethod {
                let validator = SSOLocalLoginValidator(login: self.login, deviceAccessKey: self.deviceAccessKey, apiClient: appAPIClient, serviceProviderUrl: serviceProviderUrl, cryptoEngineProvider: self.cryptoEngineProvider, isNitroProvider: isNitroProvider)
                 self.moveToUnlockStep(with: .ssoValidation(validator))
            } else {
                 self.moveToUnlockStep(with: .mpValidation)
            }
        } else {
             self.moveToUnlockStep(with: .mpValidation)
        }
    }

    public func moveToUnlockStep(with type: UnlockType) {
        let passwordUnlocker = UnlockAndLoadLocalSession(localLoginHandler: self, type: type, logger: logger)
        step = .unlock(passwordUnlocker, type)
    }

    public func validateSSOKey(_ ssoKeys: SSOKeys, loginContext: LoginContext, validator: SSOLocalLoginValidator) async throws {
        let passwordUnlocker = UnlockAndLoadLocalSession(localLoginHandler: self, type: .ssoValidation(validator, authTicket: ssoKeys.authTicket, remoteKey: ssoKeys.remoteKey), logger: logger)
        try await passwordUnlocker.unlock(with: .ssoKey(ssoKeys.ssoKey), loginContext: loginContext, isRecoveryLogin: false)
    }

    public func login(withAuthTicket authTicket: AuthTicket) async throws -> String {
        let response = try await appAPIClient.authentication.completeLoginWithAuthTicket(login: login.email, deviceAccessKey: deviceAccessKey, authTicket: authTicket.value)
        guard let serverKey = response.serverKey else {
            throw Error.noServerKey
        }
        moveToUnlockStep(with: .mpOtp2Validation(authTicket: authTicket, serverKey: serverKey))
        return serverKey
    }

    public func finish(with session: Session, isRecoveryLogin: Bool) {
        step = .completed(session, isRecoveryLogin: isRecoveryLogin)
    }

    private func makeSSOLocalLoginValidator() -> SSOLocalLoginValidator? {
        if case let .loginViaSSO(serviceProviderUrl, isNitroProvider) = loginMethod {
            let validator = SSOLocalLoginValidator(login: self.login, deviceAccessKey: self.deviceAccessKey, apiClient: self.appAPIClient, serviceProviderUrl: serviceProviderUrl, cryptoEngineProvider: cryptoEngineProvider, isNitroProvider: isNitroProvider)
            return validator
        }
        return nil
    }
}

internal struct UnlockAndLoadLocalSession: UnlockSessionHandler {
    let localLoginHandler: LocalLoginHandler
    let type: UnlockType
    let logger: Logger

    func unlock(with masterKey: MasterKey,
                loginContext: LoginContext,
                isRecoveryLogin: Bool) async throws {
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
                self.localLoginHandler.step = type.localLoginStep(with: localLoginHandler, session: session, context: loginContext, cryptoEngineProvider: localLoginHandler.cryptoEngineProvider, isRecoveryLogin: isRecoveryLogin)
            }
        } catch SessionsContainerError.cannotDecypherLocalKey {
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

public extension LocalLoginHandler {
    static var mock: LocalLoginHandler {
        LocalLoginHandler(login: Login(""), deviceInfo: .mock, deviceId: "", sessionsContainer: FakeSessionsContainer(), appAPIClient: .fake, context: nil, logger: LoggerMock(), cryptoEngineProvider: FakeCryptoEngineProvider())!
    }
}
