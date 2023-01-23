import Foundation
import DashTypes
import Combine
import DashlaneCrypto
import Cocoa
import CoreIPC
import Logger
import DashlaneAppKit

class MainApplicationCommunicationService: Mockable {
    
    private let logger: Logger

    public let lastMessage = PassthroughSubject<MainApplicationToSafariExtensionMessage, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    private let mainApplicationMessagesListener: IPCMessageListener<MainApplicationToSafariExtensionMessage>
    private let messageProducer: IPCMessageSender<SafariExtensionToMainApplicationMessage>
    
    init(logger: Logger) {
        let coder = IPCMessageCoder(logger: logger, engine: IPCCryptoEngine(encryptionKeyId: "safari-encryption-key",
                                                                            accessGroup: ApplicationGroup.keychainAccessGroup,
                                                                            cryptoCenter: CryptoCenter(from: CryptoRawConfig.keyBasedDefault.parametersHeader)!))
        mainApplicationMessagesListener = IPCMessageListener<MainApplicationToSafariExtensionMessage>(urlToObserve: MainApplicationToSafariExtensionMessage.messageFileURL,
                                                                                                      coder: coder,
                                                                                                      logger: ConsoleLogger())
        messageProducer = IPCMessageSender<SafariExtensionToMainApplicationMessage>(coder: coder,
                                                                                    destination: SafariExtensionToMainApplicationMessage.messageFileURL,
                                                                                    logger: logger)
        self.logger = logger
        
        mainApplicationMessagesListener.publisher.sink { [weak self] message in
            guard let self = self else { return }
            self.lastMessage.send(message)
        }
        .store(in: &cancellables)

    }
    
    public func send(message: SafariExtensionExternalCommunications.SafariExtensionToMainApplicationMessage) {
        openMainApplicationIfNeeded(message: message)
        messageProducer.send(message: message)
    }
    
    public func openMainAppManually() {
        NSWorkspace.shared.openMainApplication()
    }
    
    public func openSupport() {
        let url = URL.helpCenterURL
        NSWorkspace.shared.open(url,
                                completion: { [weak self] opened in
                                    if !opened {
                                        self?.logger.error("Failed to open \(url)")
                                    }
                                })
    }
    
    private func openMainApplicationIfNeeded(message: SafariExtensionExternalCommunications.SafariExtensionToMainApplicationMessage) {
        if message.needsUserInteraction {
            guard let url = DeepLink.other(.safariSessionSharing, origin: nil).urlRepresentation else {
                assertionFailure()
                return
            }
            NSWorkspace.shared.openDashlane(with: url)
        }
    }
}

private extension URL {
    static var helpCenterURL: URL {
        let code = Locale.current.languageCode ?? "en-us"
        let help = "_"
        let stringURL = String(format: help, code)
        return URL(string: stringURL)!
    }
}
