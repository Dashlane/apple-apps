import DashTypes
import Foundation
import SwiftTreats

@PersonalData
public struct PersonalWebsite: Equatable, Identifiable, DatedPersonalData {
  public static let searchCategory: SearchCategory = .personalInfo

  @Searchable
  public var name: String
  @Searchable
  public var website: String
  public var creationDatetime: Date?
  public var userModificationDatetime: Date?
  public var spaceId: String?
  @JSONEncoded
  public var attachments: Set<Attachment>?

  public init() {
    id = Identifier()
    metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
    name = ""
    website = ""
    creationDatetime = Date()
    userModificationDatetime = nil
    _attachments = .init(nil)
  }

  init(
    id: Identifier, name: String, website: String, creationDatetime: Date? = nil,
    userModificationDatetime: Date? = nil, spaceId: String? = nil
  ) {
    self.id = id
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
