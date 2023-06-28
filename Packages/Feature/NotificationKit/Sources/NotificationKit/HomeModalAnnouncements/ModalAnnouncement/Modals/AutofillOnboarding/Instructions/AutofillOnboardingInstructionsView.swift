import SwiftUI
import AVKit
import UIComponents
import DesignSystem
import CoreUserTracking
import UIDelight
import CoreLocalization

struct AutofillOnboardingInstructionsView: View {
    let model: AutofillOnboardingInstructionsViewModel

    var body: some View {
        VStack {
            PlayerView(player: model.videoPlayer)
            instructions
        }
        .onAppear {
            model.videoPlayer.play()
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(Text(L10n.Core.credentialProviderOnboardingTitle))
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationBarButton(L10n.Core.kwButtonClose) {
                    model.close()
                }
                .foregroundColor(.ds.text.neutral.catchy)
            }
        }
        .reportPageAppearance(.settingsAskAutofillActivation)
    }

    @ViewBuilder
    var instructions: some View {
        VStack(alignment: .leading) {
            Text(L10n.Core.credentialProviderOnboardingHeadLine)
                .foregroundColor(.ds.text.neutral.catchy)
                .font(DashlaneFont.custom(26, .bold).font)
            instructionsDetails
            Spacer()
            actionButton
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    var instructionsDetails: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 15) {
                Image(asset: Asset.cpOnboardingStepper1)
                Text(L10n.Core.credentialProviderOnboardingStep1)
                    .foregroundColor(.ds.text.neutral.catchy)
            }
            separator
            HStack(spacing: 15) {
                Image(asset: Asset.cpOnboardingStepper2)
                Text(L10n.Core.credentialProviderOnboardingStep2)
                    .foregroundColor(.ds.text.neutral.catchy)
            }
            separator
            HStack(spacing: 15) {
                Image(asset: Asset.cpOnboardingStepper3)
                Text(L10n.Core.credentialProviderOnboardingStep3)
                    .foregroundColor(.ds.text.neutral.catchy)
            }
            separator
            HStack(spacing: 15) {
                Image(asset: Asset.cpOnboardingStepper4)
                Text(L10n.Core.credentialProviderOnboardingStep4)
                    .foregroundColor(.ds.text.neutral.catchy)
            }
        }
    }

    var separator: some View {
        Rectangle()
            .fill(Color.ds.border.neutral.standard.active)
            .frame(width: 1, height: 12)
            .padding(.leading, 25/2)
    }

    @ViewBuilder
    var actionButton: some View {
        RoundedButton(L10n.Core.credentialProviderOnboardingCTA,
                      action: {
            model.action()
        })
        .roundedButtonLayout(.fill)
    }
}

struct AutofillOnboardingInstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        AutofillOnboardingInstructionsView(model: .init(action: {}, close: {}))
    }
}
