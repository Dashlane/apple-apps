import Foundation
import SwiftTreats
import DashTypes

public struct SecurityBreach: PersonalDataCodable, Equatable {
    public static let contentType: PersonalDataContentType = .securityBreach

    public let id: Identifier
    public let metadata: RecordMetadata
    public var breachId: String
    public var content: String
    public var contentRevision: String?
    public var leakedPasswords: String?
    public var status: Status?
    public var creationDatetime: Date?

    public enum Status: String, Codable, Defaultable {
        public static let defaultValue: Status = .default

        case pending = "PENDING"
        case acknowledged = "ACKNOWLEDGED"
        case viewed = "VIEWED"
        case solved = "SOLVED"
        case `default` = "DEFAULT"
    }

    public init() {
        id = Identifier()
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        breachId = ""
        content = ""
        contentRevision = ""
        leakedPasswords = ""
        status = .default
        creationDatetime = Date()
    }
    
    init(id: Identifier, breachId: String, content: String, contentRevision: String? = nil, leakedPasswords: String? = nil, status: SecurityBreach.Status? = nil, creationDatetime: Date? = nil) {
        self.id = id
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        self.breachId = breachId
        self.content = content
        self.contentRevision = contentRevision
        self.leakedPasswords = leakedPasswords
        self.status = status
        self.creationDatetime = creationDatetime
    }
}
