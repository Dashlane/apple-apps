import Foundation

public struct PremiumSubscriptionInfoBillingInformation: Codable, Equatable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case billingType = "billingType"
    case addressCity = "address_city"
    case addressCountry = "address_country"
    case addressLine1 = "address_line1"
    case addressLine1Check = "address_line1_check"
    case addressLine2 = "address_line2"
    case addressState = "address_state"
    case addressZip = "address_zip"
    case addressZipCheck = "address_zip_check"
    case country = "country"
    case cvcCheck = "cvc_check"
    case expMonth = "exp_month"
    case expYear = "exp_year"
    case fingerprint = "fingerprint"
    case last4 = "last4"
    case name = "name"
    case type = "type"
  }

  public let billingType: String
  public let addressCity: String?
  public let addressCountry: String?
  public let addressLine1: String?
  public let addressLine1Check: String?
  public let addressLine2: String?
  public let addressState: String?
  public let addressZip: String?
  public let addressZipCheck: String?
  public let country: String?
  public let cvcCheck: String?
  public let expMonth: Int?
  public let expYear: Int?
  public let fingerprint: String?
  public let last4: String?
  public let name: String?
  public let type: String?

  public init(
    billingType: String, addressCity: String? = nil, addressCountry: String? = nil,
    addressLine1: String? = nil, addressLine1Check: String? = nil, addressLine2: String? = nil,
    addressState: String? = nil, addressZip: String? = nil, addressZipCheck: String? = nil,
    country: String? = nil, cvcCheck: String? = nil, expMonth: Int? = nil, expYear: Int? = nil,
    fingerprint: String? = nil, last4: String? = nil, name: String? = nil, type: String? = nil
  ) {
    self.billingType = billingType
    self.addressCity = addressCity
    self.addressCountry = addressCountry
    self.addressLine1 = addressLine1
    self.addressLine1Check = addressLine1Check
    self.addressLine2 = addressLine2
    self.addressState = addressState
    self.addressZip = addressZip
    self.addressZipCheck = addressZipCheck
    self.country = country
    self.cvcCheck = cvcCheck
    self.expMonth = expMonth
    self.expYear = expYear
    self.fingerprint = fingerprint
    self.last4 = last4
    self.name = name
    self.type = type
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(billingType, forKey: .billingType)
    try container.encodeIfPresent(addressCity, forKey: .addressCity)
    try container.encodeIfPresent(addressCountry, forKey: .addressCountry)
    try container.encodeIfPresent(addressLine1, forKey: .addressLine1)
    try container.encodeIfPresent(addressLine1Check, forKey: .addressLine1Check)
    try container.encodeIfPresent(addressLine2, forKey: .addressLine2)
    try container.encodeIfPresent(addressState, forKey: .addressState)
    try container.encodeIfPresent(addressZip, forKey: .addressZip)
    try container.encodeIfPresent(addressZipCheck, forKey: .addressZipCheck)
    try container.encodeIfPresent(country, forKey: .country)
    try container.encodeIfPresent(cvcCheck, forKey: .cvcCheck)
    try container.encodeIfPresent(expMonth, forKey: .expMonth)
    try container.encodeIfPresent(expYear, forKey: .expYear)
    try container.encodeIfPresent(fingerprint, forKey: .fingerprint)
    try container.encodeIfPresent(last4, forKey: .last4)
    try container.encodeIfPresent(name, forKey: .name)
    try container.encodeIfPresent(type, forKey: .type)
  }
}
