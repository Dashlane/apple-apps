import Foundation
import CoreUserTracking
import CoreSettings
import Combine
import CoreFeature
import CorePremium
import UIKit

@MainActor
public class AutofillOnboardingFlowViewModel: HomeAnnouncementsServicesInjecting, ObservableObject {

    enum Step {
        case intro(AutofillOnboardingIntroViewModel)
        case instructions(AutofillOnboardingInstructionsViewModel)
        case success
    }

    @Published
    var steps: [Step] = []

    private let autofillService: NotificationKitAutofillServiceProtocol
    private let premiumService: PremiumServiceProtocol
    private let activityReporter: ActivityReporterProtocol
    private let userSettings: UserSettings
    private let autofillOnboardingIntroViewModelFactory: AutofillOnboardingIntroViewModel.Factory
    private let completion: @MainActor () -> Void
    private var subscriptions: Set<AnyCancellable> = .init([])

    public init(autofillService: NotificationKitAutofillServiceProtocol,
         premiumService: PremiumServiceProtocol,
         abTesttingService: ABTestingServiceProtocol,
         activityReporter: ActivityReporterProtocol,
         userSettings: UserSettings,
         autofillOnboardingIntroViewModelFactory: AutofillOnboardingIntroViewModel.Factory,
         completion: @MainActor @escaping () -> Void) {
        self.autofillService = autofillService
        self.premiumService = premiumService
        self.activityReporter = activityReporter
        self.userSettings = userSettings
        self.autofillOnboardingIntroViewModelFactory = autofillOnboardingIntroViewModelFactory
        self.completion = completion

        if abTesttingService.get(test: ABTest.AutofillIosActivationbannereducation.self)?.variant == .a {
            self.steps = [.intro(makeAutofillOnboardingIntroViewModel())]
        } else {
            self.steps = [.instructions(makeAutofillOnboardingInstructionsViewModel())]
        }

        autofillService.notificationKitActivationStatus
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { status in
                if status == .enabled {
                    self.steps.append(.success)
                }
            }
            .store(in: &subscriptions)
    }

    func onAppear() {
        userSettings[.autofillActivationPopUpHasBeenShown] = true
    }

    func finish() {
        completion()
    }
}

extension AutofillOnboardingFlowViewModel {
    var shouldShowSync: Bool {
        guard let statusCode = premiumService.status?.statusCode else {
            return false
        }
        return [PremiumStatus.StatusCode.premium,
                PremiumStatus.StatusCode.premiumRenewalStopped,
                PremiumStatus.StatusCode.freeTrial]
            .contains(statusCode)
    }

    func makeAutofillOnboardingIntroViewModel() -> AutofillOnboardingIntroViewModel {
        autofillOnboardingIntroViewModelFactory.make(shouldShowSync: shouldShowSync, action: {
            self.steps.append(.instructions(self.makeAutofillOnboardingInstructionsViewModel()))
        }, dismiss: {
            self.completion()
        })
    }

    func makeAutofillOnboardingInstructionsViewModel() -> AutofillOnboardingInstructionsViewModel {
        .init(action: {
            let settings = URL(string: "App-prefs://")!
            UIApplication.shared.open(settings)
        }, close: {
            self.completion()
        })
    }
}

extension AutofillOnboardingFlowViewModel {
    static var mock: AutofillOnboardingFlowViewModel {
        .init(autofillService: FakeNotificationKitAutofillService(),
              premiumService: PremiumServiceMock(),
              abTesttingService: ABTestingServiceMock.mock,
              activityReporter: .fake,
              userSettings: .mock,
              autofillOnboardingIntroViewModelFactory: .init({ _,_,_ in .mock }),
              completion: {})
    }
}

