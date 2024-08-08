import DesignSystem
import SwiftUI
import UIDelight

struct Dashlane2FAOnboardingView: View {
  let completion: () -> Void

  var body: some View {
    ScrollView {
      mainView
    }
    .backgroundColorIgnoringSafeArea(.ds.background.alternate)
    .navigationBarStyle(.transparent)
    .overlay(overlayButton)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(L10n.Localizable.buttonTitleSkip, action: completion)
          .foregroundColor(.ds.text.neutral.standard)
      }
    }
  }

  var mainView: some View {
    VStack {
      VStack(alignment: .center, spacing: 40) {
        Image(asset: AuthenticatorAsset.onboardingIllustration)
          .resizable()
          .scaledToFit()
        VStack(alignment: .center, spacing: 16) {
          Text(L10n.Localizable.dashlane2FaOnboardingTitle)
            .font(.authenticator(.mediumTitle))
            .multilineTextAlignment(.center)
            .foregroundColor(.ds.text.neutral.catchy)
          label
        }
      }
      Spacer()

    }
    .padding(.horizontal, 24)
  }

  var label: some View {
    Text(L10n.Localizable.dashlane2FaOnboardingSubtitle)
      .multilineTextAlignment(.center)
      .font(.body)
      .foregroundColor(.ds.text.neutral.standard)
  }

  var overlayButton: some View {
    VStack {
      Spacer()
      Button(L10n.Localizable.dashlane2FaOnboardingCta, action: completion)
        .buttonStyle(.designSystem(.titleOnly))
    }
    .padding(24)
  }
}

struct Dashlane2FAOnboardingView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview(dynamicTypePreview: true) {
      NavigationView {
        Dashlane2FAOnboardingView {}
      }
    }
  }
}
