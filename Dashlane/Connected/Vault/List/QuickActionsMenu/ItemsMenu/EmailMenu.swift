import CorePersonalData
import CoreUserTracking
import SwiftUI

struct EmailMenu: View {
  var email: Email
  let copyAction: (_ detailField: Definition.Field, _ valueToCopy: String) -> Void

  var body: some View {
    if !email.value.isEmpty {
      CopyMenuButton(L10n.Localizable.copyEmail) {
        copyAction(.email, email.value)
      }
    }
  }
}
