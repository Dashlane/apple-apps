import AutofillKit
import Combine
import CoreSettings
import DashTypes
import Foundation
import NotificationKit
import SwiftTreats

@MainActor
class HomeBottomBannerViewModel: ObservableObject, SessionServicesInjecting {
  @Published var showAutofillBanner: Bool
  @Published var shouldShowOnboardingBanner: Bool

  let action: (VaultFlowViewModel.Action) -> Void
  let onboardingChecklistViewModelFactory: OnboardingChecklistViewModel.Factory
  let onboardingAction: (OnboardingChecklistFlowViewModel.Action) -> Void
  private let userSettings: UserSettings
  private let deepLinkingService: NotificationKitDeepLinkingServiceProtocol
  private let autofillService: AutofillService

  private var subscriptions: Set<AnyCancellable> = .init()

  init(
    userSettings: UserSettings,
    deepLinkingService: NotificationKitDeepLinkingServiceProtocol,
    autofillService: AutofillService,
    action: @escaping (VaultFlowViewModel.Action) -> Void,
    onboardingChecklistViewModelFactory: OnboardingChecklistViewModel.Factory,
    onboardingAction: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void
  ) {
    self.userSettings = userSettings
    self.autofillService = autofillService
    self.deepLinkingService = deepLinkingService
    self.action = action
    self.shouldShowOnboardingBanner = userSettings.shouldShowOnboardingChecklist
    self.onboardingChecklistViewModelFactory = onboardingChecklistViewModelFactory
    self.onboardingAction = onboardingAction
    self.showAutofillBanner = autofillService.activationStatus.showAutofillBanner
    combineSetup()
  }

  private func combineSetup() {
    autofillService
      .$activationStatus
      .sink { [weak self] status in
        guard let self = self else { return }
        self.showAutofillBanner = status.showAutofillBanner
      }
      .store(in: &subscriptions)

    userSettings.settingsChangePublisher.sink { [weak self] key in
      guard let self = self else { return }
      switch key {
      case .hasUserDismissedOnboardingChecklist, .hasUserUnlockedOnboardingChecklist:
        self.shouldShowOnboardingBanner = self.userSettings.shouldShowOnboardingChecklist
      default:
        break
      }
    }.store(in: &subscriptions)
  }

  func makeAutofillBannerViewModel() -> AutofillBannerViewModel {
    AutofillBannerViewModel { [weak self] in
      switch $0 {
      case .showAutofillDemo:
        self?.action(.showAutofillDemo)
      }
    }
  }

  func makeOnboardingChecklistViewModel() -> OnboardingChecklistViewModel {
    onboardingChecklistViewModelFactory.make(action: onboardingAction)
  }
}

extension UserSettings {
  fileprivate var shouldShowOnboardingChecklist: Bool {
    let hasUserDismissedOnboardingChecklist = self[.hasUserDismissedOnboardingChecklist] ?? false
    let hasUserUnlockedOnboardingChecklist = self[.hasUserUnlockedOnboardingChecklist] ?? false

    return !hasUserDismissedOnboardingChecklist && hasUserUnlockedOnboardingChecklist
      && !Device.isMac
  }
}

extension HomeBottomBannerViewModel {
  static var mock: HomeBottomBannerViewModel {
    .init(
      userSettings: .mock,
      deepLinkingService: NotificationKitDeepLinkingServiceMock(),
      autofillService: .fakeService,
      action: { _ in },
      onboardingChecklistViewModelFactory: .init { _ in .mock },
      onboardingAction: { _ in }
    )
  }
}
