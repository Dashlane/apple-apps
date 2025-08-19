import CoreLocalization
import CoreUserTracking
import DesignSystem
import SwiftUI
import UIComponents
import UserTrackingFoundation

struct AutofillOnboardingSuccessView: View {
  let action: () -> Void

  var body: some View {
    VStack {
      Spacer()
      DS.ExpressiveIcon(.ds.feedback.success.outlined)
        .controlSize(.extraLarge)
        .style(mood: .neutral, intensity: .quiet)
      if #available(iOS 18, *) {
        Text(CoreL10n.credentialProviderOnboardingPasswordsAppCompletedTitle)
          .textStyle(.specialty.spotlight.small)
      } else {
        Text(CoreL10n.credentialProviderOnboardingCompletedTitle)
          .textStyle(.specialty.spotlight.small)
      }

      Spacer()
      Button(CoreL10n.credentialProviderOnboardingCompletedCTA, action: action)
        .buttonStyle(.designSystem(.titleOnly))
    }
    .padding(.horizontal, 20)
    .foregroundStyle(Color.ds.text.neutral.catchy)
    .navigationBarBackButtonHidden(true)
    .reportPageAppearance(.settingsConfirmAutofillActivation)
  }
}

#Preview(traits: .sizeThatFitsLayout) {
  AutofillOnboardingSuccessView {

  }
}
