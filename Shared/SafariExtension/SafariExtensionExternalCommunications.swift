import Foundation
import DashlaneAppKit

public struct SafariExtensionExternalCommunications {
    
        
    public enum SafariExtensionToMainApplicationMessage {
                                case askForSession(silently: Bool)
    }
    
    public enum MainApplicationToSafariExtensionMessage {
                                case currentUserSession(session: ShareableUserSession?)
                case sync
    }
}


private var communicationContainerURL = ApplicationGroup.containerURL.appendingPathComponent("ExtensionMessaging", isDirectory: true)

typealias SafariExtensionToMainApplicationMessage = SafariExtensionExternalCommunications.SafariExtensionToMainApplicationMessage
extension SafariExtensionExternalCommunications.SafariExtensionToMainApplicationMessage: Codable {
    static var messageFileURL: URL {
        return communicationContainerURL.appendingPathComponent("SafariToMainApp.messages")
    }
}

public typealias MainApplicationToSafariExtensionMessage = SafariExtensionExternalCommunications.MainApplicationToSafariExtensionMessage
extension SafariExtensionExternalCommunications.MainApplicationToSafariExtensionMessage: Codable {
    static var messageFileURL: URL {
        return communicationContainerURL.appendingPathComponent("MainAppToSafari.messages")
    }
}

extension SafariExtensionExternalCommunications.SafariExtensionToMainApplicationMessage {
    
    enum CodingKeys: CodingKey {
        case askForSession
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first
        switch key {
        case .askForSession:
            let silently = try container.decode(Bool.self, forKey: .askForSession)
            self = .askForSession(silently: silently)
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Unabled to decode SafariExtensionToMainApplicationMessage enum."
            ))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .askForSession(silently):
            try container.encode(silently, forKey: .askForSession)
        }
    }
}

extension SafariExtensionExternalCommunications.MainApplicationToSafariExtensionMessage {
    
    enum CodingKeys: CodingKey {
        case currentUserSession
        case sync
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first
        switch key {
        case .currentUserSession:
            let session = try container.decodeIfPresent(ShareableUserSession.self, forKey: .currentUserSession)
            self = .currentUserSession(session: session)
        case .sync:
            self = .sync
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Unabled to decode MainApplicationToSafariExtensionMessage enum."
            ))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .currentUserSession(session):
            try container.encode(session, forKey: .currentUserSession)
        case .sync:
            try container.encodeNil(forKey: .sync)
        }
    }
}

extension SafariExtensionExternalCommunications.SafariExtensionToMainApplicationMessage: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.askForSession(silentlyLhs), askForSession(silentlyRhs)):
            return silentlyLhs == silentlyRhs
        }
    }
}

extension SafariExtensionExternalCommunications.MainApplicationToSafariExtensionMessage: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.currentUserSession(sessionLhs), .currentUserSession(sessionRhs)):
            return sessionLhs == sessionRhs
        case (.sync, .sync):
            return true
        default:
            return false
        }
    }
}

extension SafariExtensionExternalCommunications.SafariExtensionToMainApplicationMessage {
    var needsUserInteraction: Bool {
        switch self {
        case let .askForSession(silently):
            return !silently
        }
    }
}
