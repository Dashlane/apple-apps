import Foundation
import SwiftUI
import UIDelight
import CoreUserTracking
import CorePremium
import CoreSettings

public class FreeTrialFlowViewModel: ObservableObject, HomeAnnouncementsServicesInjecting {

    enum Step {
        case intro
        case features
    }

    @Published
    var steps = [Step.intro]

    let trialFeaturesViewModelFactory: TrialFeaturesViewModel.Factory
    let userSettings: UserSettings

    public init(trialFeaturesViewModelFactory: TrialFeaturesViewModel.Factory,
                userSettings: UserSettings) {
        self.trialFeaturesViewModelFactory = trialFeaturesViewModelFactory
        self.userSettings = userSettings
    }

    func showTrialFeaturesView() {
        steps.append(.features)
    }

    func markTrialHasBeenShown() {
        userSettings[.trialStartedHasBeenShown] = true
    }
}

extension FreeTrialFlowViewModel {
    static var mock: FreeTrialFlowViewModel {
        return .init(trialFeaturesViewModelFactory: .init({ .mock }),
                     userSettings: UserSettings.mock)
    }
}

struct FreeTrialFlowView: View {

    @ObservedObject
    var viewModel: FreeTrialFlowViewModel

    @Environment(\.dismiss) var dismiss

    var body: some View {
        StepBasedNavigationView(steps: $viewModel.steps) { step in
            switch step {
            case .intro:
                FreeTrialStartView(learnMore: { viewModel.showTrialFeaturesView() })
            case .features:
                TrialFeaturesView(viewModel: viewModel.trialFeaturesViewModelFactory.make(), dismissFlow: dismiss)
            }
        }
        .onAppear {
            viewModel.markTrialHasBeenShown()
        }
    }
}
