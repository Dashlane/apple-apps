#if targetEnvironment(macCatalyst)
import Foundation
import CoreSession
import Combine
import SafariServices
import DashlaneCrypto
import DashTypes
import CoreIPC
import DashlaneAppKit

final class SafariExtensionService {

    private let appKitBridge: AppKitBridgeProtocol
    private let logger: Logger
    private let safariMessagesListener: IPCMessageListener<SafariExtensionToMainApplicationMessage>
    private let messageProducer: IPCMessageSender<MainApplicationToSafariExtensionMessage>
    private var cancellables = Set<AnyCancellable>()

    private var lastMessage: SafariExtensionExternalCommunications.SafariExtensionToMainApplicationMessage?

    var currentSession: Session? {
        didSet {
            self.sendSessionToSafariExtensionIfPossible()
        }
    }

    init(appKitBridge: AppKitBridgeProtocol, logger: Logger) {
        let coder = IPCMessageCoder(logger: logger, engine: KeychainBasedCryptoEngine.safariIPC(encryptionKeyId: "safari-encryption-key"))
        safariMessagesListener = IPCMessageListener<SafariExtensionToMainApplicationMessage>(urlToObserve: SafariExtensionToMainApplicationMessage.messageFileURL,
                                                                                             coder: coder, logger: logger)
        messageProducer = IPCMessageSender<MainApplicationToSafariExtensionMessage>(coder: coder,
                                                                                       destination: MainApplicationToSafariExtensionMessage.messageFileURL,
                                                                                       logger: logger)
        self.appKitBridge = appKitBridge
        self.logger = logger
        safariMessagesListener
            .publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
            self?.handle(message: message)
        }
        .store(in: &cancellables)
    }

    func unload() {
                currentSession = nil
        let message = MainApplicationToSafariExtensionMessage.currentUserSession(session: nil)
        messageProducer.send(message: message)
    }

    func refreshSafariSession() {
        sendSessionToSafariExtensionIfPossible()
    }

    private func sendSessionToSafariExtensionIfPossible() {
        guard appKitBridge.runningApplication.isSafariRunning(), let session = currentSession else {
            return
        }

        let shareableSession = ShareableUserSession(session)
        let message = MainApplicationToSafariExtensionMessage.currentUserSession(session: shareableSession)
        messageProducer.send(message: message)
    }

    private func handle(message: SafariExtensionToMainApplicationMessage) {
        switch message {
        case .askForSession:
            self.sendSessionToSafariExtensionIfPossible()
        }
        self.lastMessage = message
    }

    func performSync() {
        guard appKitBridge.runningApplication.isSafariRunning() else {
            return
        }
        messageProducer.send(message: .sync)
    }
}

private extension KeychainBasedCryptoEngine {
    static func safariIPC(encryptionKeyId: String) -> KeychainBasedCryptoEngine {
        KeychainBasedCryptoEngine(encryptionKeyId: encryptionKeyId,
                                  accessGroup: ApplicationGroup.keychainAccessGroup,
                                  allowKeyRegenerationIfFailure: true,
                                  shouldAccessAfterFirstUnlock: true)
    }
}

#endif
