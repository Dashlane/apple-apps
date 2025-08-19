import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI

struct AutoLoginSubdomainSection: View {

  @Binding
  var item: Credential

  var body: some View {
    Section {
      DS.Toggle(CoreL10n.KWAuthentifiantIOS.autoLogin, isOn: $item.autoLogin)

      DS.Toggle(CoreL10n.KWAuthentifiantIOS.subdomainOnly, isOn: $item.subdomainOnly)
    }
  }
}
