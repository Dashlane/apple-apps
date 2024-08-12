import SwiftUI
import UIComponents

struct CredentialProviderConfigurationCatalystView: View {

  let completion: () -> Void

  var body: some View {
    VStack(spacing: 40) {
      Image(asset: FiberAsset.configurationMacos)
      VStack(spacing: 10) {
        Text(L10n.Localizable.credentialAutofillSetupActivatedTitle)
          .font(.title)
        Text(L10n.Localizable.credentialAutofillSetupActivatedDescription)
          .font(.title3)
          .foregroundColor(.ds.text.neutral.quiet)
      }
      Button(L10n.Localizable.credentialAutofillSetupActivatedOk, action: completion)
        .frame(maxWidth: .infinity)
        .buttonStyle(ColoredButtonStyle())
    }
    .padding()
    .navigationBarHidden(true)
  }
}

struct CredentialProviderConfigurationCatalystView_Previews: PreviewProvider {
  static var previews: some View {
    CredentialProviderConfigurationCatalystView(completion: {})
  }
}
