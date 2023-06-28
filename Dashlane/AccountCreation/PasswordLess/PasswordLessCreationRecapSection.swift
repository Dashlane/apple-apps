import SwiftUI
import CoreLocalization
import DesignSystem
import DashTypes

struct PasswordLessCreationRecapSection: View {
    let l10n = L10n.Localizable.PasswordlessAccountCreation.Finish.self

    var body: some View {
        Section {

        } header: {
            description
                .foregroundColor(.ds.text.neutral.standard)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, -16)
                .padding(.trailing, -16)
                .padding(.top, 24)
                .textCase(nil)
        }
    }

    var description: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(l10n.title)
                .textStyle(.title.section.medium)
            Text(l10n.message)
                .textStyle(.body.standard.regular)
        }
    }
}

struct PasswordLessCreationRecapSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PasswordLessCreationRecapSection()
        }.listStyle(.insetGrouped)
    }
}
