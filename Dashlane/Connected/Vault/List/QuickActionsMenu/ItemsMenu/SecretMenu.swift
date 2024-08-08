import CoreLocalization
import CorePersonalData
import CoreUserTracking
import SwiftUI

struct SecretMenu: View {
  var secret: Secret
  let copyAction: (_ detailField: Definition.Field, _ valueToCopy: String) -> Void

  var body: some View {
    CopyMenuButton(CoreLocalization.L10n.Core.secretIDCopyActionListCTA) {
      copyAction(.secretId, secret.id.bracketLessIdentifier.rawValue)
    }
    if !secret.content.isEmpty {
      CopyMenuButton(CoreLocalization.L10n.Core.secretCopyActionListCTA) {
        copyAction(.secret, secret.content)
      }
    }
  }
}
