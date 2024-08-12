import CoreLocalization
import DashTypes
import DesignSystem
import SwiftUI

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
    .editionDisabled(appearance: .discrete)
    .fieldAppearance(.grouped)
  }
}

struct MasterPasswordCreationRecapSection_Previews: PreviewProvider {
  static var previews: some View {
    List {
      MasterPasswordCreationRecapSection(email: "_", masterPassword: "_")
    }.listStyle(.insetGrouped)
  }
}
