import AutofillKit
import Combine
import CoreFeature
import CorePersonalData
import CorePremium
import CoreSession
import CoreSettings
import DashTypes
import Foundation
import SwiftTreats
import VaultKit

class OnboardingService {
  private let session: Session
  private let loadingContext: SessionLoadingContext
  private let syncedSettings: SyncedSettingsService
  private let abTestService: ABTestingServiceProtocol
  private let guidedOnboardingSettingsProvider: GuidedOnboardingSettingsProvider
  private let lockService: LockServiceProtocol
  private let userSpacesService: UserSpacesService
  private let featureService: FeatureServiceProtocol
  private let accountType: AccountType
  let autofillService: AutofillService
  let vaultItemsStore: VaultItemsStore
  let userSettings: UserSettings
  let dwmOnboardingService: DWMOnboardingService
  let dwmOnboardingSettings: DWMOnboardingSettings
  var cancellables = Set<AnyCancellable>()

  private var isBiometricAuthenticationActivated: Bool {
    return lockService.secureLockConfigurator.isBiometricActivated
  }

  @Published
  var actions: [OnboardingChecklistAction] = []

  @Published
  var remainingActions: [OnboardingChecklistAction] = []

  @Published
  var hasPassedPasswordOnboarding: Bool = false

  @Published
  var isAutofillActivated: Bool = false

  @Published
  var hasUserDismissedOnboardingChecklist: Bool = false

  @Published
  var hasUserUnlockedOnboardingChecklist: Bool = false

  @Published
  var hasFinishedChromeImportAtLeastOnce: Bool = false

  @Published
  var hasFinishedM2WAtLeastOnce: Bool = false

  @Published
  var hasSeenDWMExperience: Bool = false

  @Published
  var hasConfirmedEmailFromOnboardingChecklist: Bool = false

  @Published
  var dwmOnboardingProgress: DWMOnboardingProgress?

  var allDone: Bool {
    guard !actions.isEmpty else { return false }
    return !actions.contains { completionState(for: $0) == .todo }
  }

  var changePublisher: AnyPublisher<Void, Never>?

  init(
    session: Session,
    loadingContext: SessionLoadingContext,
    accountType: AccountType,
    userSettings: UserSettings,
    vaultItemsStore: VaultItemsStore,
    dwmOnboardingSettings: DWMOnboardingSettings,
    dwmOnboardingService: DWMOnboardingService,
    syncedSettings: SyncedSettingsService,
    abTestService: ABTestingServiceProtocol,
    lockService: LockServiceProtocol,
    userSpacesService: UserSpacesService,
    featureService: FeatureServiceProtocol,
    autofillService: AutofillService
  ) {
    self.session = session
    self.loadingContext = loadingContext
    self.syncedSettings = syncedSettings
    self.userSettings = userSettings
    self.dwmOnboardingSettings = dwmOnboardingSettings
    self.dwmOnboardingService = dwmOnboardingService
    self.abTestService = abTestService
    self.guidedOnboardingSettingsProvider = GuidedOnboardingSettingsProvider(
      userSettings: userSettings)
    self.lockService = lockService
    self.userSpacesService = userSpacesService
    self.vaultItemsStore = vaultItemsStore
    self.featureService = featureService
    self.accountType = accountType
    self.autofillService = autofillService

    unlockOnboardingIfRequired()
    setupSubscribers()
    setupChecklist()
  }

  func setupChecklist() {
    var checklistActions: [OnboardingChecklistAction] = []
    checklistActions.append(checklistFirstAction())

    checklistActions.append(.activateAutofill)

    if session.configuration.info.accountType != .invisibleMasterPassword {
      checklistActions.append(.mobileToDesktop)
    }

    self.actions = checklistActions
    self.remainingActions = actions.filter { completionState(for: $0) == .todo }
  }

  private func checklistFirstAction() -> OnboardingChecklistAction {
    if hasConfirmedEmailFromOnboardingChecklist && dwmOnboardingProgress == .breachesNotFound {
      return .seeScanResult
    }

    if dwmOnboardingService.canShowDWMOnboarding
      && (dwmOnboardingProgress == .emailRegistrationRequestSent
        || dwmOnboardingProgress == .emailConfirmed || dwmOnboardingProgress == .breachesFound)
    {
      return .fixBreachedAccounts
    }

    let settingsProvider = GuidedOnboardingSettingsProvider(userSettings: userSettings)

    if let selectedAnswer = settingsProvider.storedAnswers[.howPasswordsHandled] {
      switch selectedAnswer {
      case .memorizePasswords, .somethingElse:
        return .addFirstPasswordsManually
      case .browser:
        return .importFromBrowser
      default:
        assertionFailure("Unacceptable answer")
      }
    }

    return .addFirstPasswordsManually
  }

  var shouldShowOnboardingChecklist: Bool {
    let hasUserDismissedOnboardingChecklist =
      self.userSettings[.hasUserDismissedOnboardingChecklist] ?? false
    let hasUserUnlockedOnboardingChecklist =
      self.userSettings[.hasUserUnlockedOnboardingChecklist] ?? false

    return !hasUserDismissedOnboardingChecklist && hasUserUnlockedOnboardingChecklist
      && !Device.isMac
  }

  var shouldShowAutofillDemo: Bool {
    let hasUserSeenAutoFillDemo = self.userSettings[.hasSeenAutofillDemo] ?? false
    return !hasUserSeenAutoFillDemo && isNewUser() && !Device.isMac
  }

  func hasSeenAutofillDemo(_ value: Bool = true) {
    self.userSettings[.hasSeenAutofillDemo] = value
  }

  var hasCreatedAtLeastOneItem: Bool {
    self.userSettings[.hasCreatedAtLeastOneItem] ?? false
  }

  var shouldShowAccountCreationOnboarding: Bool {
    guard shouldShowOnboardingChecklist else {
      return false
    }

    guard case .accountCreation = loadingContext else {
      return false
    }

    return hasSeenGuidedOnboarding == false && hasSkippedGuidedOnboarding == false
  }

  var shouldShowFastLocalSetupForFirstLogin: Bool {
    guard accountType != .invisibleMasterPassword else {
      return false
    }

    guard case .remoteLogin = loadingContext else {
      return false
    }

    guard userSettings[.fastLocalSetupForRemoteLoginDisplayed] != true else {
      return false
    }

    guard isBiometricAuthenticationActivated == false else {
      return false
    }

    return true
  }

  var shouldShowBiometricsOrPinOnboardingForSSO: Bool {
    let isSSOUser = accountType == .sso
    let hasSeenOnboarding = userSettings[.hasSeenBiometricsOrPinOnboarding] == true
    let hasConvenientMethodSetup = lockService.secureLockProvider.secureLockMode() != .masterKey
    return isSSOUser && !hasSeenOnboarding && !hasConvenientMethodSetup
  }

  func isNewUser() -> Bool {
    guard let accountCreationDate = syncedSettings[\.accountCreationDatetime] else {
      return false
    }

    guard let numberOfDaysSinceAccountCreation = Date().numberOfDays(since: accountCreationDate)
    else {
      assertionFailure()
      return false
    }

    return numberOfDaysSinceAccountCreation < 7
  }

  private var hasSeenGuidedOnboarding: Bool {
    let data: [GuidedOnboardingSettingsData]? = userSettings[.guidedOnboardingData]
    return data != nil
  }

  private var hasSkippedGuidedOnboarding: Bool {
    return userSettings[.hasSkippedGuidedOnboarding] ?? false
  }

  private func unlockOnboardingIfRequired() {
    guard (userSettings[.hasUserUnlockedOnboardingChecklist] ?? false) == false else {
      return
    }

    if isNewUser() {
      userSettings[.hasUserUnlockedOnboardingChecklist] = true
    }
  }
}

extension OnboardingService {
  static var mock: OnboardingService {
    .init(
      session: .mock,
      loadingContext: SessionLoadingContext.localLogin(),
      accountType: .masterPassword,
      userSettings: UserSettings.mock,
      vaultItemsStore: MockVaultKitServicesContainer().vaultItemsStore,
      dwmOnboardingSettings: DWMOnboardingSettings(internalStore: .mock()),
      dwmOnboardingService: DWMOnboardingService.mock,
      syncedSettings: SyncedSettingsService.mock,
      abTestService: ABTestingServiceMock.mock,
      lockService: LockServiceMock(),
      userSpacesService: UserSpacesService.mock(),
      featureService: .mock(),
      autofillService: .fakeService
    )
  }
}
