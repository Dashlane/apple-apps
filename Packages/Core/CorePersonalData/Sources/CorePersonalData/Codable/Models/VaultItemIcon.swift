import SwiftUI

public enum VaultItemIcon: Equatable {
  case address
  case bankAccount
  case company
  case creditCard(CreditCard)
  case credential(Credential)
  case drivingLicense
  case email
  case idCard
  case identity
  case passkey(Passkey)
  case passport
  case personalWebsite
  case phoneNumber
  case secret
  case secureNote(Color)
  case socialSecurityCard
  case fiscalInformation
  case wifi
  case `static`(_ asset: SwiftUI.Image, backgroundColor: SwiftUI.Color? = nil)
}
