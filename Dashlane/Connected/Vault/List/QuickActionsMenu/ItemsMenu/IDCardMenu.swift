import CorePersonalData
import SwiftUI
import UserTrackingFoundation

struct IDCardMenu: View {
  var idCard: IDCard
  let copyAction: (_ detailField: Definition.Field, _ valueToCopy: String) -> Void

  var body: some View {
    if !idCard.number.isEmpty {
      CopyMenuButton(L10n.Localizable.copyNumber) {
        copyAction(.issueNumber, idCard.number)
      }
    }

    if !idCard.displayFullName.isEmpty {
      CopyMenuButton(L10n.Localizable.copyFullName) {
        copyAction(.ownerName, idCard.displayFullName)
      }
    }
  }
}
