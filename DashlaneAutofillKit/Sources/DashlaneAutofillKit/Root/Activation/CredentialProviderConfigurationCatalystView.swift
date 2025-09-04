import SwiftUI
import UIComponents

struct CredentialProviderConfigurationCatalystView: View {

  let completion: () -> Void

  var body: some View {
    VStack(spacing: 40) {
      Image(.configurationMacos)
      VStack(spacing: 10) {
        Text(L10n.Localizable.credentialAutofillSetupActivatedTitle)
          .font(.title)
        Text(L10n.Localizable.credentialAutofillSetupActivatedDescription)
          .font(.title3)
          .foregroundStyle(Color.ds.text.neutral.quiet)
      }
      Button(L10n.Localizable.credentialAutofillSetupActivatedOk, action: completion)
        .frame(maxWidth: .infinity)
    }
    .padding()
    .navigationBarHidden(true)
    .tint(.ds.text.brand.standard)
  }
}

#Preview {
  CredentialProviderConfigurationCatalystView(completion: {})
}
