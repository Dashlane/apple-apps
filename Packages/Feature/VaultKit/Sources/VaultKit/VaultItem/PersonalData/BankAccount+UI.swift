import CoreLocalization
import CorePersonalData
import Foundation
import SwiftUI

extension BankAccount: VaultItem {
  public var enumerated: VaultItemEnumeration {
    .bankAccount(self)
  }

  public var localizedTitle: String {
    guard !name.isEmpty else {

      if let bank = bank, !bank.name.isEmpty {
        return bank.name
      }

      return CoreL10n.kwBankStatementIOS
    }
    return name
  }

  public var localizedSubtitle: String {
    guard !owner.isEmpty else {
      return CoreL10n.KWBankStatementIOS.bankAccountOwner
    }
    return owner
  }

  public static var localizedName: String {
    CoreL10n.kwBankStatementIOS
  }

  public static var addTitle: String {
    CoreL10n.kwadddatakwBankStatementIOS
  }

  public static var nativeMenuAddTitle: String {
    CoreL10n.addBankAccount
  }
}

extension BankAccount: CopiablePersonalData {

  public var valueToCopy: String {
    iban
  }

  public var fieldToCopy: DetailFieldType {
    return .bankAccountIBAN
  }
}
