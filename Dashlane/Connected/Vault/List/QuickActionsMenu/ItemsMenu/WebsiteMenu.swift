import CorePersonalData
import SwiftUI
import UserTrackingFoundation

struct WebsiteMenu: View {
  var website: PersonalWebsite
  let copyAction: (_ detailField: Definition.Field, _ valueToCopy: String) -> Void

  var body: some View {
    if !website.website.isEmpty {
      CopyMenuButton(L10n.Localizable.copyWebsite) {
        copyAction(.website, website.website)
      }
    }
  }
}
