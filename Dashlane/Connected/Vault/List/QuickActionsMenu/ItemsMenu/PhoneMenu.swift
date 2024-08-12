import CorePersonalData
import CoreUserTracking
import SwiftUI

struct PhoneMenu: View {
  var phone: Phone
  let copyAction: (_ detailField: Definition.Field, _ valueToCopy: String) -> Void

  var body: some View {
    if !phone.number.isEmpty {
      CopyMenuButton(L10n.Localizable.copyNumber) {
        copyAction(.number, phone.number)
      }
    }
  }
}
