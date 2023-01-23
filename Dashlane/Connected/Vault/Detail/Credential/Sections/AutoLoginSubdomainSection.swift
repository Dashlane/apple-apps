import CorePersonalData
import SwiftUI

struct AutoLoginSubdomainSection: View {

    @Binding
    var item: Credential

    var body: some View {
        Section {
                        ToggleDetailField(title: L10n.Localizable.KWAuthentifiantIOS.autoLogin, isOn: $item.autoLogin)

                        ToggleDetailField(title: L10n.Localizable.KWAuthentifiantIOS.subdomainOnly, isOn: $item.subdomainOnly)
        }
    }
}
