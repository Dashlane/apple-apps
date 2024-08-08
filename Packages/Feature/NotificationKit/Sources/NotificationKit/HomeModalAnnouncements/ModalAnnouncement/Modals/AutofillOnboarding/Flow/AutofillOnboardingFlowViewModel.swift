import AuthenticationServices
import Combine
import CoreFeature
import CorePremium
import CoreSettings
import CoreUserTracking
import Foundation
import UIKit

@MainActor
public class AutofillOnboardingFlowViewModel: HomeAnnouncementsServicesInjecting, ObservableObject {

  enum Step {
    case intro
    case instructions
    case success
  }

  @Published
  var steps: [Step] = []

  private let autofillService: NotificationKitAutofillServiceProtocol
  private let capabilityService: CapabilityServiceProtocol
  private let activityReporter: ActivityReporterProtocol
  private let userSettings: UserSettings
  private let autofillOnboardingIntroViewModelFactory: AutofillOnboardingIntroViewModel.Factory
  private let completion: @MainActor () -> Void
  private var subscriptions: Set<AnyCancellable> = .init([])

  public init(
    autofillService: NotificationKitAutofillServiceProtocol,
    capabilityService: CapabilityServiceProtocol,
    featureService: FeatureServiceProtocol,
    activityReporter: ActivityReporterProtocol,
    userSettings: UserSettings,
    autofillOnboardingIntroViewModelFactory: AutofillOnboardingIntroViewModel.Factory,
    completion: @MainActor @escaping () -> Void
  ) {
    self.autofillService = autofillService
    self.capabilityService = capabilityService
    self.activityReporter = activityReporter
    self.userSettings = userSettings
    self.autofillOnboardingIntroViewModelFactory = autofillOnboardingIntroViewModelFactory
    self.completion = completion

    self.steps = [.intro]

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
    capabilityService.status(of: .sync).isAvailable
  }

  func makeAutofillOnboardingIntroViewModel() -> AutofillOnboardingIntroViewModel {
    autofillOnboardingIntroViewModelFactory.make(
      shouldShowSync: shouldShowSync,
      action: {
        self.setupAutofill()
      },
      dismiss: {
        self.completion()
      })
  }

  func makeAutofillOnboardingInstructionsViewModel() -> AutofillOnboardingInstructionsViewModel {
    .init(
      action: {
        let settings = URL(string: "App-prefs://")!
        UIApplication.shared.open(settings)
      },
      close: {
        self.completion()
      })
  }

  func setupAutofill() {
    if #available(iOS 17, *) {
      ASSettingsHelper.openCredentialProviderAppSettings()
    } else {
      self.steps.append(.instructions)
    }
  }
}

extension AutofillOnboardingFlowViewModel {
  static var mock: AutofillOnboardingFlowViewModel {
    .init(
      autofillService: FakeNotificationKitAutofillService(),
      capabilityService: .mock([.init(capability: .sync, enabled: true)]),
      featureService: .mock(),
      activityReporter: .mock,
      userSettings: .mock,
      autofillOnboardingIntroViewModelFactory: .init({ _, _, _ in .mock }),
      completion: {})
  }
}
