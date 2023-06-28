import Foundation
import DashTypes
import Combine
import CoreIPC
import DashlaneAppKit
import SwiftTreats
import CoreSession
import CorePersonalData
import CoreSettings
import CoreKeychain
import CoreFeature
import AuthenticatorKit
import LoginKit
import UIKit
import DashlaneCrypto
import VaultKit
import DashlaneAPI

public protocol AuthenticatorServiceProtocol {
    func sendMessage(_ message: PasswordAppMessage)
    func addOTP(_ otp: OTPInfo) throws
    func deleteOTP(_ otp: OTPInfo)
    var codes: Set<OTPInfo> { get }
}

extension AuthenticatorAppCommunicationService: AuthenticatorServiceProtocol { }

class AuthenticatorAppCommunicationService {

    let vaultItemService: VaultItemsService
    let keychainService: AuthenticationKeychainService

    private let messageSender: IPCMessageSender<PasswordAppMessage>
    private let messageReceiver: IPCMessageListener<AutheticatorMessage>

    static let messageDirectory = ApplicationGroup.containerURL.appendingPathComponent("AuthenticatorMessaging", isDirectory: true)

    static var appToAutheticatorUrl: URL {
        return messageDirectory.appendingPathComponent("PasswordAppToAutheticatorApp.messages")
    }

    static var authenticatorToAppUrl: URL {
        return messageDirectory.appendingPathComponent("AutheticatorAppToPasswordApp.messages")
    }

    var subscriptions = Set<AnyCancellable>()

    @Published
    var codes: Set<OTPInfo> = []

    let session: Session
    let userAPIClient: UserDeviceAPIClient
    let loadingContext: SessionLoadingContext
    let databaseService: AuthenticatorDatabaseService
    let lockSettings: LocalSettingsStore
    private var authenticatorDisabler: AuthenticatorDisabler

    func unload() {
        sendMessage(.logout)
    }

    init(session: Session,
         keychainService: AuthenticationKeychainService,
         vaultItemService: VaultItemsService,
         userAPIClient: UserDeviceAPIClient,
         lockSettings: LocalSettingsStore,
         logger: Logger,
         loadingContext: SessionLoadingContext) {
        self.session = session
        self.lockSettings = lockSettings
        self.keychainService = keychainService
        self.vaultItemService = vaultItemService
        self.userAPIClient = userAPIClient
        self.loadingContext = loadingContext
        self.databaseService = AuthenticatorDatabaseService(logger: logger)
        messageReceiver = IPCMessageListener<AutheticatorMessage>(urlToObserve: AuthenticatorAppCommunicationService.authenticatorToAppUrl,
                                                                  coder: IPCMessageCoder(logger: logger, engine: KeychainBasedCryptoEngine.ipc(encryptionKeyId: "authenticator-encryption-id")),
                                                                  logger: logger)
        messageSender = IPCMessageSender<PasswordAppMessage>(coder: IPCMessageCoder(logger: logger, engine: KeychainBasedCryptoEngine.ipc(encryptionKeyId: "authenticator-encryption-id")),
                                                             destination: AuthenticatorAppCommunicationService.appToAutheticatorUrl,
                                                             logger: logger)
        self.authenticatorDisabler = AuthenticatorDisabler(userDeviceAPIClient: userAPIClient)
        databaseService.codesPublisher.assign(to: &$codes)
        vaultItemService.$credentials.receive(on: DispatchQueue.global(qos: .background)).sink { [weak self] credentials in
            guard let self = self else {
                return
            }
            let credentialsToWrite: [Credential] = credentials.filter { credential in
                credential.otpURL != nil
            }
            if !credentialsToWrite.isEmpty {
                self.sendMessage(.sync)
            }
        }.store(in: &self.subscriptions)

        keychainService.masterKeyStatusChanged.sink { [self] _ in
            Task {
                await copyAuthenticatorDBToVault()
            }
            self.sendMessage(.lockSettingsChanged)
        }.store(in: &self.subscriptions)
        if loadingContext.isFirstLogin {
            var sharedDefault = SharedUserDefault<Bool?, String>(key: AuthenticatorUserDefaultKey.showPwdAppOnboarding.rawValue)
            sharedDefault.wrappedValue = true
        }
        sendMessage(.login)
    }

    public func sendMessage(_ message: PasswordAppMessage) {
        messageSender.send(message: message)
        Task {
            await authenticatorDisabler.disableAuthenticatorIfNeeded()
        }
    }

        @MainActor
    func copyAuthenticatorDBToVault() async {
        guard loadingContext.isFirstLogin, Authenticator.isOnDevice, hasLock() else {
            return
        }
        let codesToCopy: [Credential] = databaseService.codes.filter {
            !$0.isDashlaneOTP
        }.map(Credential.init)
        _ = try? vaultItemService.save(codesToCopy)
        databaseService.codes.filter {
            !$0.isDashlaneOTP
        }.forEach(databaseService.delete)
    }

    func hasLock() -> Bool {
        let provider = SecureLockProvider(login: session.login,
                                          settings: lockSettings,
                                          keychainService: keychainService)
        let secureLockMode = provider.secureLockMode()
        return secureLockMode != .masterKey
    }

    func addOTP(_ otp: OTPInfo) throws {
        try databaseService.add([otp])
    }

    func deleteOTP(_ otp: OTPInfo) {
        databaseService.delete(otp)
    }
}

struct AuthenticatorAppCommunicatorMock: AuthenticatorServiceProtocol {
    func deleteOTP(_ otp: AuthenticatorKit.OTPInfo) {}

    var codes: Set<AuthenticatorKit.OTPInfo> {
        []
    }

    func sendMessage(_ message: PasswordAppMessage) {}
    func addOTP(_ otp: OTPInfo) throws {}
}

private struct AuthenticatorDisabler {

    let userDeviceAPIClient: UserDeviceAPIClient
    private var alreadyNotifiedServerToDisable = false

    init(userDeviceAPIClient: UserDeviceAPIClient) {
        self.userDeviceAPIClient = userDeviceAPIClient
    }

    @MainActor
    mutating func disableAuthenticatorIfNeeded() async {
        guard !Authenticator.isOnDevice, !alreadyNotifiedServerToDisable else { return }
        alreadyNotifiedServerToDisable = true
        _ = try? await userDeviceAPIClient.authenticator.disableAuthenticator()
    }

}

private extension KeychainBasedCryptoEngine {
    static func ipc(encryptionKeyId: String) -> KeychainBasedCryptoEngine {
        KeychainBasedCryptoEngine(encryptionKeyId: encryptionKeyId,
                                  accessGroup: ApplicationGroup.keychainAccessGroup,
                                  allowKeyRegenerationIfFailure: true,
                                  shouldAccessAfterFirstUnlock: true)
    }
}
