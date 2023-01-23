import Foundation

public struct AuditLogDetails: Codable, Equatable {

        public enum `Type`: String, Codable, Equatable, CaseIterable {
        case authentifiant = "AUTHENTIFIANT"
        case securenote = "SECURENOTE"
    }

        public let captureLog: Bool

        public let type: `Type`

        public let domain: String?

    public init(captureLog: Bool, type: `Type`, domain: String? = nil) {
        self.captureLog = captureLog
        self.type = type
        self.domain = domain
    }
}
