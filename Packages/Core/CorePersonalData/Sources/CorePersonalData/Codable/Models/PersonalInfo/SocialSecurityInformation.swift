import DashTypes
import Foundation
import SwiftTreats

@PersonalData("SOCIALSECURITYSTATEMENT")
public struct SocialSecurityInformation: Equatable, Identifiable, IdentityLinked, DatedPersonalData
{
  public static let searchCategory: SearchCategory = .personalInfo

  public enum Mode {
    case us
    case france
    case uk
    case other
  }

  @CodingKey("socialSecurityNumber")
  public var number: String
  @CodingKey("localeFormat")
  public var country: CountryCodeNamePair?
  @CalendarDateFormatted
  public var dateOfBirth: Date?

  @Searchable
  @Linked
  public var linkedIdentity: Identity?

  @CodingKey("socialSecurityFullname")
  public var fullname: String
  public var sex: Gender?

  public var creationDatetime: Date?
  public var userModificationDatetime: Date?

  public var spaceId: String?

  @JSONEncoded
  public var attachments: Set<Attachment>?

  @Searchable
  public var displayFullName: String {
    return linkedIdentityFullName ?? fullname
  }

  public var mode: Mode {
    guard let country = self.country ?? CountryCodeNamePair.systemCountryCode else {
      return .other
    }
    return country.socialSecurityCardMode
  }

  public init() {
    id = Identifier()
    metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
    country = CountryCodeNamePair.systemCountryCode
    fullname = ""
    number = ""
    sex = .male
    creationDatetime = Date()
    userModificationDatetime = nil
    _attachments = .init(nil)
  }

  init(
    id: Identifier,
    number: String,
    country: CountryCodeNamePair? = nil,
    dateOfBirth: String?,
    linkedIdentity: Identifier?,
    fullname: String, sex: Gender? = nil,
    creationDatetime: Date? = nil,
    userModificationDatetime: Date? = nil,
    spaceId: String? = nil
  ) {
    self.id = id
    metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
    self.number = number
    self.country = country
    self._dateOfBirth = CalendarDateFormatted(rawValue: dateOfBirth)
    self._linkedIdentity = Linked(identifier: linkedIdentity)
    self.fullname = fullname
    self.sex = sex
    self.creationDatetime = creationDatetime
    self.userModificationDatetime = userModificationDatetime
    self.spaceId = spaceId
    _attachments = .init(nil)
  }
}

extension SocialSecurityInformation {
  public func validate() throws {
    if fullname.isEmptyOrWhitespaces() && number.isEmptyOrWhitespaces() {
      let invalidProperty =
        fullname.isEmptyOrWhitespaces() ? \SocialSecurityInformation.fullname : \.number
      throw ItemValidationError(invalidProperty: invalidProperty)
    }
  }
}

extension CountryCodeNamePair {
  var socialSecurityCardMode: SocialSecurityInformation.Mode {
    if ["US"].contains(code) {
      return .us
    } else if ["FR"].contains(code) {
      return .france
    } else if ["GB"].contains(code) {
      return .uk
    }
    return .other
  }
}
