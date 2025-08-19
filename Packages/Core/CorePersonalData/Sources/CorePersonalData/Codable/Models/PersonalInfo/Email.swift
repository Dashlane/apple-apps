import CoreTypes
import Foundation
import LogFoundation
import SwiftTreats

@Loggable
@PersonalData
public struct Email: Equatable, Identifiable, DatedPersonalData {
  public static let searchCategory: SearchCategory = .personalInfo

  public enum EmailType: String, Codable, Defaultable, CaseIterable, Identifiable {
    public static let defaultValue: EmailType = .personal

    public var id: String {
      return self.rawValue
    }

    case personal = "PERSO"
    case work = "PRO"
  }

  @Searchable
  @CodingKey("email")
  public var value: String

  @Searchable
  @CodingKey("emailName")
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

  public init(
    id: Identifier = .init(), value: String, name: String, creationDatetime: Date? = .init(),
    userModificationDatetime: Date? = .init(), type: Email.EmailType? = nil,
    localeFormat: String = "", spaceId: String? = nil
  ) {
    self.id = id
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

extension Email {
  public func validate() throws {
    if value.isEmptyOrWhitespaces() {
      throw ItemValidationError(invalidProperty: \Email.value)
    }
  }
}
