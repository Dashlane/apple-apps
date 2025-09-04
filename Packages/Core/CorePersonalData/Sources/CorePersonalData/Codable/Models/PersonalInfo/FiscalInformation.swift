import CoreTypes
import Foundation
import LogFoundation
import SwiftTreats

@Loggable
@PersonalData("FISCALSTATEMENT")
public struct FiscalInformation: Equatable, Identifiable, DatedPersonalData {
  public static let searchCategory: SearchCategory = .personalInfo

  @Searchable
  public var fiscalNumber: String
  @Searchable
  @CodingKey("teledeclarantNumber")
  public var teledeclarationNumber: String

  public var creationDatetime: Date?
  public var userModificationDatetime: Date?

  @CodingKey("localeFormat")
  public var country: CountryCodeNamePair?
  public var spaceId: String?
  @JSONEncoded
  public var attachments: Set<Attachment>?

  public enum Mode {
    case franceAndBelgium
    case other
  }

  public var mode: Mode {
    guard let country = self.country ?? CountryCodeNamePair.systemCountryCode else {
      return .other
    }
    return country.fiscalMode
  }

  public init() {
    id = Identifier()
    metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
    fiscalNumber = ""
    teledeclarationNumber = ""
    creationDatetime = Date()
    country = CountryCodeNamePair.systemCountryCode
    _attachments = .init(nil)
  }

  init(
    id: Identifier, fiscalNumber: String, teledeclarationNumber: String,
    creationDatetime: Date? = nil, userModificationDatetime: Date? = nil,
    country: CountryCodeNamePair? = nil, spaceId: String? = nil
  ) {
    self.id = id
    metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
    self.fiscalNumber = fiscalNumber
    self.teledeclarationNumber = teledeclarationNumber
    self.creationDatetime = creationDatetime
    self.userModificationDatetime = userModificationDatetime
    self.country = country
    self.spaceId = spaceId
    _attachments = .init(nil)
  }

}

extension FiscalInformation {
  public func validate() throws {
    if fiscalNumber.isEmptyOrWhitespaces() {
      throw ItemValidationError(invalidProperty: \FiscalInformation.fiscalNumber)
    }
  }
}

extension CountryCodeNamePair {
  var fiscalMode: FiscalInformation.Mode {
    if ["FR", "BE"].contains(code) {
      return .franceAndBelgium
    }
    return .other
  }
}
