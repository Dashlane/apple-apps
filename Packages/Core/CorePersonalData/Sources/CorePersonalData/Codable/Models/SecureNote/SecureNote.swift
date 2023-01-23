import Foundation
import DashTypes
import SwiftTreats

public struct SecureNote: PersonalDataCodable, Equatable, Identifiable, Categorisable, DatedPersonalData {
    public typealias CategoryType = SecureNoteCategory
    public static let contentType: PersonalDataContentType = .secureNote
    public static let searchCategory: SearchCategory = .secureNote

    enum CodingKeys: String, CodingKey {
        case id
        case category
        case anonId
        case metadata
        case title
        case content
        case color = "type"
        case secured
        case creationDatetime
        case userModificationDatetime
        case spaceId
        case attachments
    }

    public let id: Identifier
    @Linked
    public var category: SecureNoteCategory?
    public var anonId: String
    public let metadata: RecordMetadata
    public var title: String
    public var content: String
    public var color: SecureNoteColor
    public var secured: Bool
    public var creationDatetime: Date?
    public var userModificationDatetime: Date?
    public var spaceId: String?
    @JSONEncoded
    public var attachments: Set<Attachment>?

            public init() {
        id = Identifier()
        anonId = UUID().uuidString
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        title = ""
        content = ""
        color = SecureNoteColor.gray
        secured = false
        creationDatetime = Date()
        spaceId = nil
        _attachments = .init(nil)
    }

    public init(id: Identifier = .init(),
                category: Linked<SecureNoteCategory> = .init(nil),
                anonId: String = "",
                title: String,
                content: String,
                color: SecureNoteColor = .gray,
                secured: Bool = false,
                creationDatetime: Date? = nil,
                userModificationDatetime: Date? = nil,
                spaceId: String? = nil,
                attachments: Set<Attachment>? = nil) {
        self.id = id
        self._category = category
        self.anonId = anonId
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        self.title = title
        self.content = content
        self.color = color
        self.secured = secured
        self.creationDatetime = creationDatetime
        self.userModificationDatetime = userModificationDatetime
        self.spaceId = spaceId
        _attachments = .init(attachments)
    }

    public func validate() throws {
        if title.isEmptyOrWhitespaces() {
            throw ItemValidationError(invalidProperty: \SecureNote.title)
        }
    }
    
    public var rawId: String {
        return id.rawValue
    }
}

extension SecureNote: Searchable {
    public var searchableKeyPaths: [KeyPath<SecureNote, String>] {
        guard !self.secured else {
            return []
        }
        return [\SecureNote.content]
    }
}

extension SecureNote: Displayable {
    public var displayTitle: String {
        return title
    }
    public var displaySubtitle: String? {
        return content
    }
}
