import SwiftUI
import DesignSystem

struct SettingsCryptographySectionContent: View {
    let derivationKey: String

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text(L10n.Localizable.kwKeyDerivationAlgo)
                .foregroundColor(.ds.text.neutral.standard)
                .textStyle(.body.standard.regular)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(derivationKey)
                .foregroundColor(.ds.text.neutral.quiet)
                .textStyle(.body.standard.regular)
        }
    }
}

struct SettingsCryptographySectionContent_Previews: PreviewProvider {
    static var previews: some View {
        SettingsCryptographySectionContent(derivationKey: "FakeDerivationKey")
    }
}
