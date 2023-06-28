import CorePersonalData
import DesignSystem
import SwiftUI
import CoreLocalization

struct AutoLoginSubdomainSection: View {

    @Binding
    var item: Credential

    var body: some View {
        Section {
                        DS.Toggle(CoreLocalization.L10n.Core.KWAuthentifiantIOS.autoLogin, isOn: $item.autoLogin)

                        DS.Toggle(CoreLocalization.L10n.Core.KWAuthentifiantIOS.subdomainOnly, isOn: $item.subdomainOnly)
        }
    }
}
