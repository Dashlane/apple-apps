import SwiftUI
import UIComponents
import DesignSystem
import CoreLocalization

struct AutofillOnboardingSuccessView: View {
    let action: () -> Void

    var body: some View {
        VStack {
            Spacer()
            Image(asset: Asset.introCheckmark)
            Text(L10n.Core.credentialProviderOnboardingCompletedTitle)
                .font(DashlaneFont.custom(26, .bold).font)
            Spacer()
            RoundedButton(L10n.Core.credentialProviderOnboardingCompletedCTA, action: action)
                .roundedButtonLayout(.fill)
        }
        .padding(.horizontal, 20)
        .foregroundColor(.ds.text.neutral.catchy)
        .navigationBarBackButtonHidden(true)
        .reportPageAppearance(.settingsConfirmAutofillActivation)
    }
}
