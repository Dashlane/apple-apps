import Combine
import CorePersonalData
import Foundation
import SwiftUI

extension ItemCategory {
  public struct Item: Identifiable {
    public let type: VaultItem.Type

    public var id: String {
      self.type.localizedName
    }

    init(_ type: VaultItem.Type) {
      self.type = type
    }
  }

  public var items: [Item] {
    switch self {
    case .credentials:
      return [Credential.self].map(Item.init)
    case .secureNotes:
      return [SecureNote.self].map(Item.init)
    case .secrets:
      return [Secret.self].map(Item.init)
    case .payments:
      return [
        CreditCard.self,
        BankAccount.self,
      ].map(Item.init)
    case .personalInfo:
      return [
        Identity.self,
        Email.self,
        Phone.self,
        Address.self,
        Company.self,
        PersonalWebsite.self,
      ].map(Item.init)
    case .ids:
      return [
        Passport.self,
        DrivingLicence.self,
        SocialSecurityInformation.self,
        IDCard.self,
        FiscalInformation.self,
      ].map(Item.init)
    }
  }
}
