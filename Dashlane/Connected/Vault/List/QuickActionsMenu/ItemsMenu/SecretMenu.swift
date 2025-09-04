import CoreLocalization
import CorePersonalData
import SwiftUI
import UserTrackingFoundation

struct SecretMenu: View {
  var secret: Secret
  let copyAction: (_ detailField: Definition.Field, _ valueToCopy: String) -> Void

  var body: some View {
    CopyMenuButton(CoreL10n.secretIDCopyActionListCTA) {
      copyAction(.secretId, secret.id.bracketLessIdentifier.rawValue)
    }
    if !secret.content.isEmpty {
      CopyMenuButton(CoreL10n.secretCopyActionListCTA) {
        copyAction(.secret, secret.content)
      }
    }
  }
}
