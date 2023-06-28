import Foundation
import SwiftTreats
import DashTypes

public struct PersonalWebsite: PersonalDataCodable, Equatable, Identifiable, DatedPersonalData {

    public static let contentType: PersonalDataContentType = .website
    public static let searchCategory: SearchCategory = .personalInfo

    public enum CodingKeys: String, CodingKey {
        case id
        case anonId
        case metadata
        case name
        case website
        case creationDatetime
        case userModificationDatetime
        case spaceId
        case attachments
    }

    public let id: Identifier
    public var anonId: String
    public let metadata: RecordMetadata
    public var name: String
    public var website: String
    public var creationDatetime: Date?
    public var userModificationDatetime: Date?
    public var spaceId: String?
    @JSONEncoded
    public var attachments: Set<Attachment>?

    public init() {
        id = Identifier()
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        anonId = UUID().uuidString
        name = ""
        website = ""
        creationDatetime = Date()
        userModificationDatetime = nil
        _attachments = .init(nil)
    }

    init(id: Identifier, anonId: String, name: String, website: String, creationDatetime: Date? = nil, userModificationDatetime: Date? = nil, spaceId: String? = nil) {
        self.id = id
        self.anonId = anonId
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        self.name = name
        self.website = website
        self.creationDatetime = creationDatetime
        self.userModificationDatetime = userModificationDatetime
        self.spaceId = spaceId
        _attachments = .init(nil)
    }

    public func validate() throws {
        if name.isEmptyOrWhitespaces() {
            throw ItemValidationError(invalidProperty: \PersonalWebsite.name)
        }
    }
}

extension PersonalWebsite: Searchable {

    public var searchableKeyPaths: [KeyPath<PersonalWebsite, String>] {
        let keyPathsList: [KeyPath<PersonalWebsite, String>] = [
            \PersonalWebsite.name,
            \PersonalWebsite.website
        ]
        return keyPathsList
    }
}
