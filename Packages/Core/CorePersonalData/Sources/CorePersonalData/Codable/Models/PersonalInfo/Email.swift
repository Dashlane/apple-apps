import Foundation
import SwiftTreats
import DashTypes

public struct Email: PersonalDataCodable, Equatable, Identifiable, DatedPersonalData {
    public static let contentType: PersonalDataContentType = .email
    public static let searchCategory: SearchCategory = .personalInfo

    public enum CodingKeys: String, CodingKey {
        case id
        case anonId
        case metadata
        case value = "email"
        case name = "emailName"
        case creationDatetime
        case userModificationDatetime
        case type
        case localeFormat
        case spaceId
        case attachments
    }

    public enum EmailType: String, Codable, Defaultable, CaseIterable, Identifiable {
        public static let defaultValue: EmailType = .personal

        public var id: String {
            return self.rawValue
        }
        
        case personal = "PERSO"
        case work = "PRO"
    }
    
    public let id: Identifier
    public var anonId: String
    public let metadata: RecordMetadata
    public var value: String
    public var name: String
    public var creationDatetime: Date?
    public var userModificationDatetime: Date?
    public var type: EmailType?
    public var localeFormat: String
    public var spaceId: String?
    @JSONEncoded
    public var attachments: Set<Attachment>?

    public init() {
        id = Identifier()
        anonId = UUID().uuidString
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        value = ""
        name = ""
        creationDatetime = Date()
        userModificationDatetime = nil
        type = .personal
        localeFormat = "UNIVERSAL"
        spaceId = nil
        _attachments = .init(nil)
    }
    
    public init(id: Identifier = .init(), anonId: String = UUID().uuidString, value: String, name: String, creationDatetime: Date? = .init(), userModificationDatetime: Date? = .init(), type: Email.EmailType? = nil, localeFormat: String = "", spaceId: String? = nil) {
        self.id = id
        self.anonId = anonId
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        self.value = value
        self.name = name
        self.creationDatetime = creationDatetime
        self.userModificationDatetime = userModificationDatetime
        self.type = type
        self.localeFormat = localeFormat
        self.spaceId = spaceId
        _attachments = .init(nil)
    }
}

extension Email: Searchable {
    public var searchableKeyPaths: [KeyPath<Email, String>] {
        return [
            \Email.value,
            \Email.name
        ]
    }
}

extension Email {
    public func validate() throws {
        if value.isEmptyOrWhitespaces() {
            throw ItemValidationError(invalidProperty: \Email.value)
        }
    }
}
