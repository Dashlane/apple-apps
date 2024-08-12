import DashTypes
import Foundation
import SwiftTreats

@PersonalData
public struct Secret: Equatable, Identifiable, DatedPersonalData {
  public static let searchCategory: SearchCategory = .credential

  public var spaceId: String?
  @Searchable
  public var title: String
  @Searchable
  public var content: String
  public var secured: Bool
  public var creationDatetime: Date?
  public var userModificationDatetime: Date?

  @JSONEncoded
  public var attachments: Set<Attachment>?

  public init() {
    id = Identifier()
    metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
    title = ""
    content = ""
    secured = false
    creationDatetime = Date()
    _attachments = .init(nil)
  }

  public init(
    id: Identifier = .init(),
    title: String,
    content: String,
    secured: Bool = false,
    creationDatetime: Date? = nil,
    userModificationDatetime: Date? = nil
  ) {
    self.id = id
    _attachments = .init(nil)
    metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
    self.title = title
    self.content = content
    self.secured = secured
    self.creationDatetime = creationDatetime
    self.userModificationDatetime = userModificationDatetime
  }

  public func validate() throws {
    if title.isEmptyOrWhitespaces() {
      throw ItemValidationError(invalidProperty: \Secret.title)
    }
  }

  public var rawId: String {
    return id.rawValue
  }
}

extension Secret: Deduplicable {

  public var deduplicationKeyPaths: [KeyPath<Self, String>] {
    [
      \Secret.title,
      \Secret.content,
    ]
  }
}

extension Secret: Displayable {
  public var displayTitle: String {
    return title
  }
  public var displaySubtitle: String? {
    return content
  }
}
