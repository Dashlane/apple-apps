import CoreLocalization
import DesignSystem
import SwiftUI
import UIComponents

struct AutofillOnboardingSuccessView: View {
  let action: () -> Void

  var body: some View {
    VStack {
      Spacer()
      Image(asset: Asset.introCheckmark)
      Text(L10n.Core.credentialProviderOnboardingCompletedTitle)
        .font(DashlaneFont.custom(26, .bold).font)
      Spacer()
      Button(L10n.Core.credentialProviderOnboardingCompletedCTA, action: action)
        .buttonStyle(.designSystem(.titleOnly))
    }
    .padding(.horizontal, 20)
    .foregroundColor(.ds.text.neutral.catchy)
    .navigationBarBackButtonHidden(true)
    .reportPageAppearance(.settingsConfirmAutofillActivation)
  }
}
