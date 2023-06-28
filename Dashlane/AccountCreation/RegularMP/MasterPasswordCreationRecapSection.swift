import SwiftUI
import CoreLocalization
import DesignSystem
import DashTypes

struct MasterPasswordCreationRecapSection: View {
    @State
    var email: String

    @State
    var masterPassword: String

    var body: some View {
        Section {
            DS.TextField(CoreLocalization.L10n.Core.kwEmailIOS, text: $email)
            DS.PasswordField(CoreLocalization.L10n.Core.masterPassword, text: $masterPassword)
        } header: {
            Text(L10n.Localizable.minimalisticOnboardingRecapTitle)
                .textStyle(.specialty.brand.small)
                .foregroundColor(.ds.text.neutral.standard)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, -16)
                .padding(.bottom, 16)
                .padding(.top, 52)
                .textCase(nil)
        }
        .editionDisabled()
        .textFieldDisabledEditionAppearance(.discrete)
        .textFieldAppearance(.grouped)
    }
}

struct MasterPasswordCreationRecapSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            MasterPasswordCreationRecapSection(email: "_", masterPassword: "Dashlane12")
        }.listStyle(.insetGrouped)
    }
}
