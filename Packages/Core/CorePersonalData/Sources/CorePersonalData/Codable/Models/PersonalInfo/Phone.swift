import CoreTypes
import Foundation
import LogFoundation
import SwiftTreats

@Loggable
@PersonalData
public struct Phone: Equatable, Identifiable, Hashable, DatedPersonalData {
  public static let searchCategory: SearchCategory = .personalInfo

  public enum NumberType: String, Codable, Defaultable, CaseIterable, Identifiable {
    public static let defaultValue: NumberType = .none
    public var id: String {
      return self.rawValue
    }

    case mobile = "PHONE_TYPE_MOBILE"
    case fax = "PHONE_TYPE_FAX"
    case landline = "PHONE_TYPE_LANDLINE"
    case workMobile = "PHONE_TYPE_WORK_MOBILE"
    case workLandline = "PHONE_TYPE_WORK_LANDLINE"
    case workFax = "PHONE_TYPE_WORK_FAX"
    case none = "PHONE_TYPE_ANY"
  }

  @Searchable
  @CodingKey("phoneName")
  public var name: String

  @Searchable
  public var number: String

  @Searchable
  @CodingKey("numberNational")
  public var nationalNumber: String

  @Searchable
  @CodingKey("numberInternational")
  public var interNationalNumber: String

  public var type: NumberType?
  @CodingKey("localeFormat")
  public var country: CountryCodeNamePair?
  public var creationDatetime: Date?
  public var userModificationDatetime: Date?
  public var spaceId: String?
  @JSONEncoded
  public var attachments: Set<Attachment>?

  public init() {
    id = Identifier()
    metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
    number = ""
    name = ""
    creationDatetime = Date()
    userModificationDatetime = nil
    nationalNumber = ""
    interNationalNumber = ""
    type = .mobile
    country = nil
    _attachments = .init(nil)
  }

  init(
    id: Identifier,
    name: String,
    number: String,
    nationalNumber: String,
    interNationalNumber: String,
    type: Phone.NumberType? = nil,
    country: CountryCodeNamePair? = nil,
    creationDatetime: Date? = nil,
    userModificationDatetime: Date? = nil,
    spaceId: String? = nil
  ) {
    self.id = id
    metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
    self.name = name
    self.number = number
    self.creationDatetime = creationDatetime
    self.userModificationDatetime = userModificationDatetime
    self.nationalNumber = nationalNumber
    self.interNationalNumber = interNationalNumber
    self.type = type
    self.country = country
    self.spaceId = spaceId
    _attachments = .init(nil)
  }

  public func validate() throws {
    if number.isEmptyOrWhitespaces() {
      throw ItemValidationError(invalidProperty: \Phone.number)
    }
  }
}

extension Phone {
  public var displayPhone: String {
    if !interNationalNumber.isEmpty {
      return interNationalNumber
    } else if !nationalNumber.isEmpty {
      return nationalNumber
    }
    return number
  }
}
