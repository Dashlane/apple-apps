import CorePersonalData
import CoreUserTracking
import SwiftUI

struct BankAccountMenu: View {
  var bankAccount: BankAccount
  let copyAction: (_ detailField: Definition.Field, _ valueToCopy: String) -> Void

  var body: some View {
    if !bankAccount.bic.isEmpty {
      CopyMenuButton(bankAccount.bicVariant.copyLabel) {
        copyAction(.bic, bankAccount.bic)
      }
    }

    if !bankAccount.iban.isEmpty {
      CopyMenuButton(bankAccount.ibanVariant.copyLabel) {
        copyAction(.iban, bankAccount.iban)
      }
    }
  }
}

extension BICVariant {
  fileprivate var copyLabel: String {
    switch self {
    case .bic:
      return L10n.Localizable.copyBic
    case .routingNumber:
      return L10n.Localizable.copyRouting
    case .sortcode:
      return L10n.Localizable.copySortCode
    }
  }
}

extension IBANVariant {
  fileprivate var copyLabel: String {
    switch self {
    case .iban:
      return L10n.Localizable.copyIBAN
    case .account:
      return L10n.Localizable.copyAccountNumber
    case .clabe:
      return L10n.Localizable.copyClabe
    }
  }
}
