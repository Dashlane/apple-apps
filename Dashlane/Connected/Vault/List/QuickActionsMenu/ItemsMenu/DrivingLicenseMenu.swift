import CorePersonalData
import CoreUserTracking
import SwiftUI

struct DrivingLicenseMenu: View {
  var drivingLicense: DrivingLicence
  let copyAction: (_ detailField: Definition.Field, _ valueToCopy: String) -> Void

  var body: some View {
    if !drivingLicense.number.isEmpty {
      CopyMenuButton(L10n.Localizable.copyNumber) {
        copyAction(.issueNumber, drivingLicense.number)
      }
    }

    if !drivingLicense.displayFullName.isEmpty {
      CopyMenuButton(L10n.Localizable.copyFullName) {
        copyAction(.ownerName, drivingLicense.displayFullName)
      }
    }
  }
}
