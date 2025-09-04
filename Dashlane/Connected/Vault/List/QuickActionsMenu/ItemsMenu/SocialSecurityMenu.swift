import CorePersonalData
import SwiftUI
import UserTrackingFoundation

struct SocialSecurityMenu: View {
  var socialSecurity: SocialSecurityInformation
  let copyAction: (_ detailField: Definition.Field, _ valueToCopy: String) -> Void

  var body: some View {
    if !socialSecurity.number.isEmpty {
      CopyMenuButton(L10n.Localizable.copyNumber) {
        copyAction(.socialSecurityNumber, socialSecurity.number)
      }
    }

    if !socialSecurity.displayFullName.isEmpty {
      CopyMenuButton(L10n.Localizable.copyFullName) {
        copyAction(.ownerName, socialSecurity.displayFullName)
      }
    }
  }
}
