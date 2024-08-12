import Foundation

extension Definition {

  public struct `FieldsFilled`: Encodable, Sendable {
    public init(
      `address`: Int? = nil, `bankStatement`: Int? = nil, `company`: Int? = nil,
      `credential`: Int? = nil, `creditCard`: Int? = nil, `driverLicense`: Int? = nil,
      `email`: Int? = nil, `fiscalStatement`: Int? = nil, `generatedPassword`: Int? = nil,
      `idCard`: Int? = nil, `identity`: Int? = nil, `passkey`: Int? = nil, `passport`: Int? = nil,
      `paypal`: Int? = nil, `phone`: Int? = nil, `secureNote`: Int? = nil,
      `securityBreach`: Int? = nil, `socialSecurity`: Int? = nil, `website`: Int? = nil
    ) {
      self.address = address
      self.bankStatement = bankStatement
      self.company = company
      self.credential = credential
      self.creditCard = creditCard
      self.driverLicense = driverLicense
      self.email = email
      self.fiscalStatement = fiscalStatement
      self.generatedPassword = generatedPassword
      self.idCard = idCard
      self.identity = identity
      self.passkey = passkey
      self.passport = passport
      self.paypal = paypal
      self.phone = phone
      self.secureNote = secureNote
      self.securityBreach = securityBreach
      self.socialSecurity = socialSecurity
      self.website = website
    }
    public let address: Int?
    public let bankStatement: Int?
    public let company: Int?
    public let credential: Int?
    public let creditCard: Int?
    public let driverLicense: Int?
    public let email: Int?
    public let fiscalStatement: Int?
    public let generatedPassword: Int?
    public let idCard: Int?
    public let identity: Int?
    public let passkey: Int?
    public let passport: Int?
    public let paypal: Int?
    public let phone: Int?
    public let secureNote: Int?
    public let securityBreach: Int?
    public let socialSecurity: Int?
    public let website: Int?
  }
}
