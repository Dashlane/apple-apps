import Contacts
import DashTypes
import Foundation
import SwiftTreats

@PersonalData
public struct Address: Equatable, Identifiable, Hashable, DatedPersonalData {
  public static let searchCategory: SearchCategory = .personalInfo

  public enum Mode {
    case europe
    case europeWithState
    case japan
    case asia
    case unitedKingdom
    case northAmericaAndAustralasia
  }

  @Searchable
  @CodingKey("addressName")
  public var name: String

  @Searchable
  public var addressFull: String

  public var streetNumber: String

  @Searchable
  public var streetName: String

  @Searchable
  public var zipCode: String

  @Searchable
  public var city: String

  public var state: StateCodeNamePair?
  public var country: CountryCodeNamePair?
  public var localeFormat: CountryCodeNamePair?

  public var linkedPhone: Identifier?
  @Searchable
  public var receiver: String
  @Searchable
  public var building: String
  public var stairs: String
  public var floor: String
  public var door: String
  public var digitCode: String
  public var creationDatetime: Date?
  public var userModificationDatetime: Date?
  public var spaceId: String?
  @JSONEncoded
  public var attachments: Set<Attachment>?

  public var mode: Mode {
    guard let country = self.country ?? CountryCodeNamePair.systemCountryCode else {
      return .europe
    }
    return country.addressMode
  }

  public init() {
    id = Identifier()
    metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
    name = ""
    streetNumber = ""
    addressFull = ""
    streetName = ""
    zipCode = ""
    city = ""
    state = nil
    linkedPhone = nil
    receiver = ""
    building = ""
    stairs = ""
    floor = ""
    door = ""
    digitCode = ""
    country = CountryCodeNamePair.systemCountryCode
    creationDatetime = Date()
    _attachments = .init(nil)
  }

  init(
    id: Identifier,
    name: String,
    addressFull: String,
    streetNumber: String,
    streetName: String,
    zipCode: String,
    city: String,
    state: StateCodeNamePair? = nil,
    country: CountryCodeNamePair? = nil,
    localeFormat: CountryCodeNamePair? = nil,
    linkedPhone: Identifier? = nil,
    receiver: String,
    building: String,
    stairs: String,
    floor: String,
    door: String,
    digitCode: String,
    creationDatetime: Date? = nil,
    userModificationDatetime: Date? = nil,
    spaceId: String? = nil
  ) {
    self.id = id
    metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
    self.name = name
    self.addressFull = addressFull
    self.streetNumber = streetNumber
    self.streetName = streetName
    self.zipCode = zipCode
    self.city = city
    self.state = state
    self.country = country
    self.localeFormat = localeFormat
    self.linkedPhone = linkedPhone
    self.receiver = receiver
    self.building = building
    self.stairs = stairs
    self.floor = floor
    self.door = door
    self.digitCode = digitCode
    self.creationDatetime = creationDatetime
    self.userModificationDatetime = userModificationDatetime
    self.spaceId = spaceId
    _attachments = .init(nil)
  }

  mutating func link(with phone: Phone) {
    self.linkedPhone = phone.id
  }
}

extension Address {
  public func validate() throws {
    if city.isEmptyOrWhitespaces() {
      throw ItemValidationError(invalidProperty: \Address.city)
    }
  }
}

extension Address {
  public mutating func prepareForSaving() {
    switch mode {
    case .unitedKingdom:
      addressFull = [streetName, streetNumber].filter { !$0.isEmpty }.joined(separator: " ")
    default:
      streetName = ""
      streetNumber = ""
    }

    localeFormat = country
  }
}

extension CountryCodeNamePair {
  var addressMode: Address.Mode {
    if ["AT", "DK", "FR", "LU"].contains(code) {
      return .europe
    } else if ["AR", "BE", "CH", "CL", "CO", "DE", "ES", "IT", "NL", "NO", "PE", "PT", "SE", "MX"]
      .contains(code)
    {
      return .europeWithState
    } else if ["JP"].contains(code) {
      return .japan
    } else if ["CN", "IN", "KR", "BR"].contains(code) {
      return .asia
    } else if ["GB", "IE"].contains(code) {
      return .unitedKingdom
    } else if ["AU", "CA", "US", "NZ"].contains(code) {
      return .northAmericaAndAustralasia
    }
    return .europe
  }
}

extension Address {
  public var displayAddress: String {
    let address = CNMutablePostalAddress(address: self)
    let formatter = CNPostalAddressFormatter()
    return formatter.string(from: address)
  }

  public var hasStairs: Bool {
    guard let code = country?.code else { return false }
    return !["GB", "US"].contains(code)
  }
}

extension CNMutablePostalAddress {
  convenience init(address: Address) {
    self.init()

    if !address.zipCode.isEmpty {
      self.postalCode = address.zipCode
    }
    if let country = address.country {
      if !country.name.isEmpty {
        self.country = country.name
      }
      self.isoCountryCode = country.code
    }

    if let state = address.state?.name, !state.isEmpty {
      self.state = state
    }

    if address.mode == .unitedKingdom {
      let street = [address.streetNumber, address.streetName]
        .filter { !$0.isEmpty }.joined(separator: " ")
      if !street.isEmpty {
        self.street = street
      }
    } else if !address.addressFull.isEmpty {
      self.street = address.addressFull
    }

    if !address.city.isEmpty {
      self.city = address.city
    }
  }
}
