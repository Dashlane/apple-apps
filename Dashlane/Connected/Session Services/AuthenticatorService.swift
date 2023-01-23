import Foundation
import DashTypes
import Combine
import CoreIPC
import DashlaneAppKit
import CoreSession
import CorePersonalData
import SwiftTreats
import CoreSettings
import AuthenticatorKit
import CoreKeychain
import LoginKit
import UIKit

class AuthenticatorService: Mockable {

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

    let session: Session
    let accountAPIClient: AuthenticatedAccountAPIClientProtocol
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
         accountAPIClient: AuthenticatedAccountAPIClientProtocol,
         authenticatorDatabase: AuthenticatorDatabaseService,
         lockSettings: LocalSettingsStore,
         logger: Logger,
         loadingContext: SessionLoadingContext) {
        self.session = session
        self.lockSettings = lockSettings
        self.keychainService = keychainService
        self.vaultItemService = vaultItemService
        self.accountAPIClient = accountAPIClient
        self.loadingContext = loadingContext
        self.databaseService = authenticatorDatabase
        messageReceiver = IPCMessageListener<AutheticatorMessage>(urlToObserve: AuthenticatorService.authenticatorToAppUrl,
                                                                  coder: IPCMessageCoder(logger: logger, engine: IPCCryptoEngine(encryptionKeyId: "authenticator-encryption-id")),
                                                                  logger: logger)
        messageSender = IPCMessageSender<PasswordAppMessage>(coder: IPCMessageCoder(logger: logger, engine: IPCCryptoEngine(encryptionKeyId: "authenticator-encryption-id")),
                                                             destination: AuthenticatorService.appToAutheticatorUrl,
                                                             logger: logger)
        self.authenticatorDisabler = AuthenticatorDisabler(accountAPIClient: accountAPIClient)

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
        if loadingContext == .accountCreation || loadingContext == .remoteLogin {
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
        guard loadingContext != .localLogin, UIApplication.hasAuthenticatorApp(), hasLock() else {
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
}

struct AuthenticatorAppCommunicatorMock: AuthenticatorServiceProtocol {
    func sendMessage(_ message: PasswordAppMessage) {

    }
}

private extension UIApplication {
    @MainActor
    static func hasAuthenticatorApp() -> Bool {
        shared.canOpenURL(DashlaneURLFactory.authenticator)
    }
}

private struct AuthenticatorDisabler {

    let accountAPIClient: AuthenticatedAccountAPIClientProtocol
    private var alreadyNotifiedServerToDisable = false

    init(accountAPIClient: AuthenticatedAccountAPIClientProtocol) {
        self.accountAPIClient = accountAPIClient
    }

    @MainActor
    mutating func disableAuthenticatorIfNeeded() async {
        guard !UIApplication.hasAuthenticatorApp(), !alreadyNotifiedServerToDisable else { return }
        alreadyNotifiedServerToDisable = true
        try? await accountAPIClient.disableAuthenticator()
    }

}
