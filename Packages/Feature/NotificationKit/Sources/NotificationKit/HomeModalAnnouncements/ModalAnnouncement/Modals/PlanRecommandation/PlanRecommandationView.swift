import SwiftUI
import UIDelight
import UIComponents
import DesignSystem
import CoreUserTracking
import CoreLocalization

struct PlanRecommandationView: View {

    let viewModel: PlanRecommandationViewModel

    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .center), content: {

            VStack(alignment: .leading, spacing: 0, content: {
                HStack(alignment: .top, spacing: 20, content: {
                    Spacer()
                    AnnouncementCloseButton(dismiss: {
                        viewModel.cancelAction()
                        dismiss()
                    })
                })
                .padding()
                Spacer()
            })

            VStack(spacing: 10) {
                Spacer()
                LottieView(.diamond, loopMode: .loop, animated: true)
                    .scaleEffect(1.6)
                    .frame(width: 218, height: 163, alignment: .center)
                Text(L10n.Core.actionItemTrialUpgradeRecommendationTitle)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                Text(text)
                    .font(.callout)
                    .foregroundColor(.ds.text.neutral.standard)
                RoundedButton(buttonText, action: viewModel.learnMore)
                    .roundedButtonLayout(.fill)
                    .padding(.top, 36)
                Spacer()

            }
            .padding()
        })
        .backgroundColorIgnoringSafeArea(.ds.background.default)
        .reportPageAppearance(.trialUpgradeSuggestion)
        .onAppear {
            viewModel.markPlanRecommandationHasBeenShown()
        }
    }
}

extension PlanRecommandationView {
    var text: String {
        switch viewModel.recommendedPlan {
        case .premium:
            return L10n.Core.actionItemTrialUpgradeRecommendationDescriptionPremium
        }
    }

    var buttonText: String {
        switch viewModel.recommendedPlan {
        case .premium:
            return L10n.Core.currentPlanCtaPremium
        }
    }
}

struct PlanRecommandationView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(deviceRange: .mainScreenSizes) {
            PlanRecommandationView(viewModel: .init(deepLinkingService: NotificationKitDeepLinkingServiceMock(),
                                                    activityReporter: .fake, userSettings: .mock))
        }
    }
}
