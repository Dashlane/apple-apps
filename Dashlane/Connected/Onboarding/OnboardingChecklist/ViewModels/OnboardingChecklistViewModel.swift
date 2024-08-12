import AuthenticationServices
import AutofillKit
import Combine
import CoreFeature
import CorePremium
import CoreSession
import CoreSettings
import CoreUserTracking
import DashTypes
import Foundation
@preconcurrency import Lottie
import NotificationKit
import UIComponents
import VaultKit

enum OnboardingChecklistDismissability: String {
  case nonDismissable
  case dismissableTimeOver
  case dismissableAllDone
}

@MainActor
class OnboardingChecklistViewModel: ObservableObject, SessionServicesInjecting {

  let userSettings: UserSettings
  let dwmOnboardingSettings: DWMOnboardingSettings
  let dwmOnboardingService: DWMOnboardingService
  private let onboardingService: OnboardingService
  let autofillService: AutofillService
  private let featureService: FeatureServiceProtocol
  private let capabilityService: CapabilityServiceProtocol
  private let activityReporter: ActivityReporterProtocol
  var cancellables = Set<AnyCancellable>()
  let userSpaceSwitcherViewModelFactory: UserSpaceSwitcherViewModel.Factory

  var isSecureNoteDisabled: Bool {
    featureService.isEnabled(.disableSecureNotes)
  }

  private var animationLoadingTask: Task<LottieAnimation?, Never>?

  @Published
  var dismissability: OnboardingChecklistDismissability = .nonDismissable

  @Published
  var dismissButtonCTA: String?

  @Published
  var actions: [OnboardingChecklistAction] = []

  var hasPassedPasswordOnboarding: Bool {
    onboardingService.hasPassedPasswordOnboarding
  }

  @Published
  var selectedAction: OnboardingChecklistAction?

  var isAutofillActivated: Bool {
    onboardingService.isAutofillActivated
  }

  var hasFinishedM2WAtLeastOnce: Bool {
    onboardingService.hasFinishedM2WAtLeastOnce
  }

  var hasSeenDWMExperience: Bool {
    onboardingService.hasSeenDWMExperience
  }

  let action: (OnboardingChecklistFlowViewModel.Action) -> Void
  private let session: Session

  init(
    session: Session,
    userSettings: UserSettings,
    dwmOnboardingSettings: DWMOnboardingSettings,
    dwmOnboardingService: DWMOnboardingService,
    capabilityService: CapabilityServiceProtocol,
    featureService: FeatureServiceProtocol,
    onboardingService: OnboardingService,
    autofillService: AutofillService,
    activityReporter: ActivityReporterProtocol,
    action: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void,
    userSpaceSwitcherViewModelFactory: UserSpaceSwitcherViewModel.Factory
  ) {
    self.session = session
    self.userSettings = userSettings
    self.featureService = featureService
    self.dwmOnboardingSettings = dwmOnboardingSettings
    self.dwmOnboardingService = dwmOnboardingService
    self.onboardingService = onboardingService
    self.autofillService = autofillService
    self.activityReporter = activityReporter
    self.capabilityService = capabilityService
    self.userSpaceSwitcherViewModelFactory = userSpaceSwitcherViewModelFactory
    self.action = action

    self.onboardingService.$remainingActions
      .receive(on: DispatchQueue.main)
      .sink { [weak self] remainingActions in
        self?.updateDismissability()
        self?.selectedAction = remainingActions.first
      }
      .store(in: &cancellables)

    self.onboardingService.$actions
      .receive(on: DispatchQueue.main)
      .assign(to: &$actions)
  }

  func updateDismissability() {
    if onboardingService.allDone {
      dismissability = .dismissableAllDone
      dismissButtonCTA = L10n.Localizable.onboardingChecklistV2DismissAction
    } else if onboardingService.isNewUser() == false {
      dismissability = .dismissableTimeOver
      dismissButtonCTA = L10n.Localizable.onboardingChecklistV2DismissTimeOver
    } else {
      dismissability = .nonDismissable
      dismissButtonCTA = nil
    }
  }

  @MainActor
  func didTapDismiss() {
    self.userSettings[.hasUserDismissedOnboardingChecklist] = true

    if onboardingService.allDone {
      showDismissAnimation {
        self.dismiss()
      }
    } else {
      self.dismiss()
    }
  }

  func validatePasswordOnboarding() {
    onboardingService.hasPassedPasswordOnboarding = true
  }

  func select(_ action: OnboardingChecklistAction) {
    guard onboardingService.completionState(for: action) == .todo else { return }
    selectedAction = action
  }

  func start(_ checklistAction: OnboardingChecklistAction) {
    action(.ctaTapped(action: checklistAction))
  }

  func updateOnAppear() {
    action(.onAppear)
    preLoadAnimation()
  }

  func preLoadAnimation() {
    animationLoadingTask = Task { () -> LottieAnimation? in
      return LottieAsset.onboardingConfettis.animation()
    }
  }

  func dismiss() {
    self.cancellables.forEach { $0.cancel() }
    action(.onDismiss)
  }

  func onAddItemDropdown() {
    activityReporter.reportPageShown(.homeAddItemDropdown)
  }

  func addNewItemAction(mode: AddItemFlowViewModel.DisplayMode) {
    action(.addNewItem(displayMode: mode))
  }

  @MainActor
  private func showDismissAnimation(completion: @escaping () -> Void) {
    Task {
      guard let animation = await animationLoadingTask?.value else { return }
      let animationView = LottieAnimationView(animation: animation)

      if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
        let window = sceneDelegate.window
      {
        let animation = animationView
        animation.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        animation.contentMode = .scaleAspectFill
        animation.loopMode = .playOnce
        animation.animationSpeed = 1
        animation.isUserInteractionEnabled = false
        window.addSubview(animation)
        animation.frame = window.bounds
      }

      completion()
      animationView.play { _ in
        animationView.removeFromSuperview()
      }
    }
  }
}

extension OnboardingChecklistViewModel {
  static var mock: OnboardingChecklistViewModel {
    OnboardingChecklistViewModel(
      session: .mock,
      userSettings: .mock,
      dwmOnboardingSettings: .init(internalStore: .mock()),
      dwmOnboardingService: .mock,
      capabilityService: .mock(),
      featureService: .mock(),
      onboardingService: .mock,
      autofillService: .fakeService,
      activityReporter: .mock,
      action: { _ in },
      userSpaceSwitcherViewModelFactory: .init({ .mock })
    )
  }
}
