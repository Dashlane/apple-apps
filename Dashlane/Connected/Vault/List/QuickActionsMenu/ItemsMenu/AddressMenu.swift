import CorePersonalData
import CoreUserTracking
import SwiftUI

struct AddressMenu: View {
  var address: Address
  let copyAction: (_ detailField: Definition.Field, _ valueToCopy: String) -> Void

  var body: some View {
    if !address.displayAddress.isEmpty {
      CopyMenuButton(L10n.Localizable.copyAddress) {
        copyAction(.addressName, address.displayAddress)
      }
    }

    if !address.zipCode.isEmpty {
      CopyMenuButton(L10n.Localizable.copyZip) {
        copyAction(.zipCode, address.zipCode)
      }
    }

    if !address.city.isEmpty {
      CopyMenuButton(L10n.Localizable.copyCity) {
        copyAction(.city, address.city)
      }
    }
  }
}
