import Foundation
import DashTypes
import Combine
import CoreIPC
import TOTPGenerator
import DashlaneAppKit

class PasswordAppCommunicator {
    private let messageSender: IPCMessageSender<AuthenticatorMessage>
    private let messageReceiver: IPCMessageListener<PasswordAppMessage>
    var messageSubscriptions = Set<AnyCancellable>()
    private let appState: ApplicationStateService
    static let messageDirectory = ApplicationGroup.containerURL.appendingPathComponent("AuthenticatorMessaging", isDirectory: true)
    
    static var passwordAppToAuthenticatorUrl: URL {
        return messageDirectory.appendingPathComponent("PasswordAppToAuthenticatorApp.messages")
    }
    
    static var authenticatorToPasswordAppUrl: URL {
        return messageDirectory.appendingPathComponent("AuthenticatorAppToPasswordApp.messages")
    }
    
    init(logger: Logger, appState: ApplicationStateService) {
        self.appState = appState
        messageReceiver = IPCMessageListener<PasswordAppMessage>(urlToObserve: PasswordAppCommunicator.passwordAppToAuthenticatorUrl,
                                                                    coder: IPCMessageCoder(logger: logger, engine: IPCCryptoEngine(encryptionKeyId: "authenticator-encryption-id")),
                                                                    logger: logger)
        messageSender = IPCMessageSender<AuthenticatorMessage>(coder: IPCMessageCoder(logger: logger, engine: IPCCryptoEngine(encryptionKeyId: "authenticator-encryption-id")),
                                              destination: PasswordAppCommunicator.authenticatorToPasswordAppUrl,
                                                                                       logger: logger)
        messageReceiver
            .publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.appState.handle(message)
        }
        .store(in: &messageSubscriptions)
        messageReceiver.read()
    }
}
