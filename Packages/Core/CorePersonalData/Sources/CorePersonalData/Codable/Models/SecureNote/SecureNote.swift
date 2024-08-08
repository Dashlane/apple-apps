import DashTypes
import Foundation
import SwiftTreats

@PersonalData
public struct SecureNote: Equatable, Identifiable, DatedPersonalData {
  public typealias CategoryType = SecureNoteCategory
  public static let searchCategory: SearchCategory = .secureNote

  public let id: Identifier
  public var title: String
  public var content: String
  @CodingKey("type")
  public var color: SecureNoteColor
  public var secured: Bool
  public var creationDatetime: Date?
  public var userModificationDatetime: Date?
  public var spaceId: String?
  @JSONEncoded
  public var attachments: Set<Attachment>?

  @Searchable
  var unsecuredContent: String? {
    secured ? nil : content
  }

  public init() {
    id = Identifier()
    metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
    title = ""
    content = ""
    color = SecureNoteColor.gray
    secured = false
    creationDatetime = Date()
    spaceId = nil
    _attachments = .init(nil)
  }

  public init(
    id: Identifier = .init(),
    title: String,
    content: String,
    color: SecureNoteColor = .gray,
    secured: Bool = false,
    creationDatetime: Date? = nil,
    userModificationDatetime: Date? = nil,
    spaceId: String? = nil,
    attachments: Set<Attachment>? = nil
  ) {
    self.id = id
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
}

extension SecureNote: Deduplicable {

  public var deduplicationKeyPaths: [KeyPath<Self, String>] {
    [
      \SecureNote.title,
      \SecureNote.content,
    ]
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
