import Foundation
import DashTypes
import SwiftTreats

public struct Company: PersonalDataCodable, Equatable, Identifiable, DatedPersonalData {
    public static let contentType: PersonalDataContentType = .company
    public static let searchCategory: SearchCategory = .personalInfo

    public enum CodingKeys: String, CodingKey {
        case id
        case anonId
        case metadata
        case name
        case jobTitle
        case creationDatetime
        case userModificationDatetime
        case spaceId
        case attachments
    }

    public let id: Identifier
    public var anonId: String
    public let metadata: RecordMetadata
    public var name: String
    public var jobTitle: String
    public var creationDatetime: Date?
    public var userModificationDatetime: Date?
    public var spaceId: String?
    @JSONEncoded
    public var attachments: Set<Attachment>?

    public init() {
        id = Identifier()
        anonId = UUID().uuidString
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        name = ""
        jobTitle = ""
        creationDatetime = Date()
        userModificationDatetime = nil
        _attachments = .init(nil)
    }
    
    init(id: Identifier, anonId: String, name: String, jobTitle: String, creationDatetime: Date? = nil, userModificationDatetime: Date? = nil, spaceId: String? = nil) {
        self.id = id
        self.anonId = anonId
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        self.name = name
        self.jobTitle = jobTitle
        self.creationDatetime = creationDatetime
        self.userModificationDatetime = userModificationDatetime
        self.spaceId = spaceId
        _attachments = .init(nil)
    }

    public func validate() throws {
        if name.isEmptyOrWhitespaces() {
            throw ItemValidationError(invalidProperty: \Company.name)
        }
    }
}

extension Company: Searchable {
    
    public var searchableKeyPaths: [KeyPath<Company, String>] {
        return [
            \Company.name,
            \Company.jobTitle
        ]
    }
}
