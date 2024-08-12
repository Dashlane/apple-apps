import DesignSystem
import SwiftUI
import UIDelight

struct PairedModeOnboardingView: View {
  let mode: AuthenticationMode
  let completion: () -> Void

  var body: some View {
    ScrollView {
      mainView
    }.backgroundColorIgnoringSafeArea(.ds.background.alternate)
      .navigationBarStyle(.transparent)
      .overlay(overlayButton)
  }

  var mainView: some View {
    VStack {
      VStack(alignment: .center, spacing: 40) {
        Image(asset: AuthenticatorAsset.onboardingIllustration)
          .resizable()
          .scaledToFit()
        VStack(alignment: .center, spacing: 16) {
          Text(L10n.Localizable.passwordappOnboardingTitle)
            .font(.authenticator(.mediumTitle))
            .multilineTextAlignment(.center)
            .foregroundColor(.ds.text.neutral.catchy)
          label
        }
      }.padding(.bottom, 40)
      Spacer()
    }
    .padding(.horizontal, 24)
    .padding(.bottom, 24)
  }

  var label: some View {
    Text(lockLabelAttributedString)
      .multilineTextAlignment(.center)
      .font(.body)
      .foregroundColor(.ds.text.neutral.standard)
  }

  private var lockLabelAttributedString: AttributedString {
    let markdownLockLabel = mode.lockLabel.replacingOccurrences(
      of: mode.displayName, with: "**\(mode.displayName)**")
    return (try? AttributedString(markdown: markdownLockLabel)) ?? AttributedString(mode.lockLabel)
  }

  var overlayButton: some View {
    VStack {
      Spacer()
      Button(L10n.Localizable.passwordappOnboardingButtonTitle, action: completion)
        .buttonStyle(.designSystem(.titleOnly))
    }
    .padding(24)
  }
}

struct PairedModeOnboardingView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview(dynamicTypePreview: true) {
      NavigationView {
        PairedModeOnboardingView(
          mode: .pincode(.init(code: "1234", attempts: .mock, masterKey: .masterPassword("_")))
        ) {}
      }
    }
    MultiContextPreview(dynamicTypePreview: true) {
      NavigationView {
        PairedModeOnboardingView(mode: .biometry(.faceId)) {}
      }
    }
  }
}
