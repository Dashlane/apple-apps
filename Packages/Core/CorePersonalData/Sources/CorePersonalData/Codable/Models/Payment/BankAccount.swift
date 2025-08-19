import CoreTypes
import Foundation
import LogFoundation
import SwiftTreats

@Loggable
@PersonalData("BANKSTATEMENT")
public struct BankAccount: Equatable, Identifiable, DatedPersonalData {
  public static let searchCategory: SearchCategory = .payment

  @CodingKey("bankAccountName")
  public var name: String

  @Searchable
  @CodingKey("bankAccountBank")
  public var bank: BankCodeNamePair?

  @CodingKey("bankAccountBIC")
  public var bic: String

  @CodingKey("bankAccountIBAN")
  public var iban: String

  @Searchable
  @CodingKey("bankAccountOwner")
  public var owner: String

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
    bank = nil
    bic = ""
    iban = ""
    name = ""
    owner = ""
    _attachments = .init(nil)
    country = CountryCodeNamePair.systemCountryCode
    creationDatetime = Date()
  }

  init(
    id: Identifier = .init(),
    name: String = "",
    bank: BankCodeNamePair? = nil,
    bic: String,
    iban: String,
    owner: String = "",
    country: CountryCodeNamePair? = nil,
    creationDatetime: Date? = nil,
    userModificationDatetime: Date? = nil,
    spaceId: String? = nil
  ) {
    self.id = id
    metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
    self.name = name
    self.bank = bank
    self.bic = bic
    self.iban = iban
    self.owner = owner
    self.country = country
    self.creationDatetime = creationDatetime
    self.userModificationDatetime = userModificationDatetime
    self.spaceId = spaceId
    _attachments = .init(nil)
  }

  public func validate() throws {
    if name.isEmptyOrWhitespaces() && bank == nil {
      throw ItemValidationError(invalidProperty: \BankAccount.name)
    } else if bic.isEmptyOrWhitespaces() {
      throw ItemValidationError(invalidProperty: \BankAccount.bic)
    }
  }
}

extension BankAccount: Deduplicable {

  public var deduplicationKeyPaths: [KeyPath<Self, String>] {
    [
      \BankAccount.iban,
      \BankAccount.bic,
      \BankAccount.name,
    ]
  }
}
