import CorePersonalData
import SwiftUI
import UserTrackingFoundation

struct PassportMenu: View {
  var passport: Passport
  let copyAction: (_ detailField: Definition.Field, _ valueToCopy: String) -> Void

  var body: some View {
    if !passport.number.isEmpty {
      CopyMenuButton(L10n.Localizable.copyNumber) {
        copyAction(.issueNumber, passport.number)
      }
    }

    if !passport.displayFullName.isEmpty {
      CopyMenuButton(L10n.Localizable.copyFullName) {
        copyAction(.ownerName, passport.displayFullName)
      }
    }
  }
}
