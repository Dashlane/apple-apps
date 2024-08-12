import CorePersonalData
import CoreUserTracking
import SwiftUI

struct CreditCardMenu: View {
  var creditCard: CreditCard
  let copyAction: (_ detailField: Definition.Field, _ valueToCopy: String) -> Void

  var body: some View {
    if !creditCard.cardNumber.isEmpty {
      CopyMenuButton(L10n.Localizable.copyCardNumber) {
        copyAction(.cardNumber, creditCard.cardNumber)
      }
    }

    if !creditCard.securityCode.isEmpty {
      CopyMenuButton(L10n.Localizable.copySecurityCode) {
        copyAction(.securityCode, creditCard.securityCode)
      }
    }
  }
}
