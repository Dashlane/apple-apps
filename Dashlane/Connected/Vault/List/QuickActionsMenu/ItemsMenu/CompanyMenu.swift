import CorePersonalData
import CoreUserTracking
import SwiftUI

struct CompanyMenu: View {
  var company: Company
  let copyAction: (_ detailField: Definition.Field, _ valueToCopy: String) -> Void

  var body: some View {
    if !company.jobTitle.isEmpty {
      CopyMenuButton(L10n.Localizable.copyTitle) {
        copyAction(.jobTitle, company.jobTitle)
      }
    }

    if !company.name.isEmpty {
      CopyMenuButton(L10n.Localizable.copyName) {
        copyAction(.name, company.name)
      }
    }
  }
}
