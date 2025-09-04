import CoreLocalization
import DesignSystem
import SwiftUI
import SwiftUILottie
import UIComponents
import UIDelight
import UserTrackingFoundation

struct PlanRecommandationView: View {

  let viewModel: PlanRecommandationViewModel

  @Environment(\.dismiss) var dismiss

  var body: some View {
    ZStack(
      alignment: Alignment(horizontal: .center, vertical: .center),
      content: {

        VStack(
          alignment: .leading, spacing: 0,
          content: {
            HStack(
              alignment: .top, spacing: 20,
              content: {
                Spacer()
                AnnouncementCloseButton(dismiss: {
                  viewModel.cancelAction()
                  dismiss()
                })
              }
            )
            .padding()
            Spacer()
          })

        VStack(spacing: 10) {
          Spacer()
          LottieView(.diamond, loopMode: .loop, animated: true)
            .scaleEffect(1.6)
            .frame(width: 218, height: 163, alignment: .center)
          Text(CoreL10n.actionItemTrialUpgradeRecommendationTitle)
            .font(.title)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
          Text(text)
            .font(.callout)
            .foregroundStyle(Color.ds.text.neutral.standard)
          Button(buttonText, action: viewModel.learnMore)
            .buttonStyle(.designSystem(.titleOnly))
            .padding(.top, 36)
          Spacer()

        }
        .padding()
      }
    )
    .background(Color.ds.background.default, ignoresSafeAreaEdges: .all)
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
      return CoreL10n.actionItemTrialUpgradeRecommendationDescriptionPremium
    }
  }

  var buttonText: String {
    switch viewModel.recommendedPlan {
    case .premium:
      return CoreL10n.currentPlanCtaPremium
    }
  }
}

#Preview {
  PlanRecommandationView(
    viewModel: .init(
      deepLinkingService: NotificationKitDeepLinkingServiceMock(),
      activityReporter: .mock, userSettings: .mock))
}
