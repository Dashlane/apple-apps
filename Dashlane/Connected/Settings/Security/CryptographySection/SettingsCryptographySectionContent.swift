import SwiftUI

struct SettingsCryptographySectionContent: View {

    let derivationKey: String

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text(L10n.Localizable.kwKeyDerivationAlgo)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(derivationKey)
                .foregroundColor(.secondary)
        }
    }
}

struct SettingsCryptographySectionContent_Previews: PreviewProvider {
    static var previews: some View {
        SettingsCryptographySectionContent(derivationKey: "FakeDerivationKey")
    }
}
