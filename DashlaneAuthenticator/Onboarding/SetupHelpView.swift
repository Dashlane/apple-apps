import DesignSystem
import Foundation
import SwiftUI
import UIComponents

struct SetupHelpView: View {
  let image: ImageAsset
  let caption: String
  let title: String
  let helpTitle: String
  let helpMessage: String
  let primaryButton: (title: String, action: () -> Void)
  let secondaryButtonTitle: String
  let skipAction: () -> Void

  @State var showHelp: Bool = false

  var body: some View {
    VStack(alignment: .leading, spacing: 100) {
      mainView
      buttonView
    }
    .padding(.horizontal, 24)
    .padding(.bottom, 24)
    .sheet(isPresented: $showHelp) {
      BottomSheet(
        helpTitle,
        description: helpMessage,
        actions: {
          Button(L10n.Localizable.buttonTitleOkGotIt) {
            showHelp = false
          }
          .buttonStyle(.designSystem(.titleOnly))
        }
      )
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: skipAction) {
          Text(L10n.Localizable.buttonTitleSkip)
        }
      }
    }
  }

  var mainView: some View {
    FullScreenScrollView {
      VStack(alignment: .center, spacing: 0) {
        Image(asset: image)
          .padding(.bottom, 80)
        Text(caption)
          .padding(.bottom, 16)
          .foregroundColor(.ds.text.neutral.quiet)
          .font(.caption)
        Text(title)
          .multilineTextAlignment(.center)
          .foregroundColor(.ds.text.neutral.catchy)
          .font(.authenticator(.mediumTitle))
      }
      .padding(.horizontal, 23)
    }
  }

  var buttonView: some View {
    VStack(spacing: 23) {
      Button(primaryButton.title, action: primaryButton.action)
      Button(secondaryButtonTitle) {
        showHelp = true
      }
      .style(intensity: .supershy)
      .font(.body.weight(.medium))
      .foregroundColor(.ds.text.brand.standard)
    }
    .buttonStyle(.designSystem(.titleOnly))
  }
}

struct SetupHelpView_Previews: PreviewProvider {
  static var previews: some View {
    SetupHelpView(
      image: AuthenticatorAsset.onboardingStep1,
      caption: L10n.Localizable.stepLabel("1"),
      title: L10n.Localizable.tokenAccountHelpTitle,
      helpTitle: L10n.Localizable.tokenAccountHelpCta,
      helpMessage: L10n.Localizable.tokenAccountHelpMessage,
      primaryButton: (title: L10n.Localizable.buttonTitleNext, action: {}),
      secondaryButtonTitle: L10n.Localizable.tokenAccountHelpCta
    ) {}
    SetupHelpView(
      image: AuthenticatorAsset.onboardingStep2,
      caption: L10n.Localizable.stepLabel("2"),
      title: L10n.Localizable.tokenSettingsHelpTitle,
      helpTitle: L10n.Localizable.tokenSettingsHelpCta,
      helpMessage: L10n.Localizable.tokenSettingsHelpMessage,
      primaryButton: (title: L10n.Localizable.buttonTitleNext, action: {}),
      secondaryButtonTitle: L10n.Localizable.tokenSettingsHelpCta
    ) {}
    SetupHelpView(
      image: AuthenticatorAsset.onboardingStep3,
      caption: L10n.Localizable.stepLabel("3"),
      title: L10n.Localizable.tokenCodesHelpTitle,
      helpTitle: L10n.Localizable.tokenCodesHelpCta,
      helpMessage: L10n.Localizable.tokenCodesHelpMessage,
      primaryButton: (title: L10n.Localizable.setupHelpAddTokenCta, action: {}),
      secondaryButtonTitle: L10n.Localizable.tokenCodesHelpCta
    ) {}
  }
}
