import Foundation

public struct AuditLogDetails: Codable, Equatable {

        public enum `Type`: String, Codable, Equatable, CaseIterable {
        case authentifiant = "AUTHENTIFIANT"
        case securenote = "SECURENOTE"
    }

    private enum CodingKeys: String, CodingKey {
        case type = "type"
        case captureLog = "captureLog"
        case domain = "domain"
    }

        public let type: `Type`

        public let captureLog: Bool?

        public let domain: String?

    public init(type: `Type`, captureLog: Bool? = nil, domain: String? = nil) {
        self.type = type
        self.captureLog = captureLog
        self.domain = domain
    }
}
