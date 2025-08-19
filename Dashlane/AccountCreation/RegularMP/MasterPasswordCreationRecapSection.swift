import CoreLocalization
import CoreTypes
import DesignSystem
import SwiftUI

struct MasterPasswordCreationRecapSection: View {
  @State
  var email: String

  @State
  var masterPassword: String

  var body: some View {
    Section {
      DS.TextField(CoreL10n.kwEmailIOS, text: $email)
      DS.PasswordField(CoreL10n.masterPassword, text: $masterPassword)
    } header: {
      Text(L10n.Localizable.minimalisticOnboardingRecapTitle)
        .textStyle(.specialty.brand.small)
        .foregroundStyle(Color.ds.text.neutral.standard)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.leading, -16)
        .padding(.bottom, 16)
        .padding(.top, 52)
        .textCase(nil)
    }
    .fieldEditionDisabled(appearance: .discrete)
  }
}

struct MasterPasswordCreationRecapSection_Previews: PreviewProvider {
  static var previews: some View {
    List {
      MasterPasswordCreationRecapSection(email: "_", masterPassword: "_")
    }.listStyle(.ds.insetGrouped)
  }
}
