import AutofillKit
import Combine
import CoreFeature
import CorePersonalData
import CorePremium
import CoreSession
import CoreSettings
import CoreTypes
import Foundation
import SwiftTreats
import VaultKit

class OnboardingService {
  private let session: Session
  private let loadingContext: SessionLoadingContext
  private let syncedSettings: SyncedSettingsService
  private let abTestService: ABTestingServiceProtocol
  private let lockService: LockServiceProtocol
  private let userSpacesService: UserSpacesService
  private let featureService: FeatureServiceProtocol
  private let accountType: AccountType
  let autofillService: AutofillStateServiceProtocol
  let vaultItemsStore: VaultItemsStore
  let userSettings: UserSettings
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
    syncedSettings: SyncedSettingsService,
    abTestService: ABTestingServiceProtocol,
    lockService: LockServiceProtocol,
    userSpacesService: UserSpacesService,
    featureService: FeatureServiceProtocol,
    autofillService: AutofillStateServiceProtocol
  ) {
    self.session = session
    self.loadingContext = loadingContext
    self.syncedSettings = syncedSettings
    self.userSettings = userSettings
    self.abTestService = abTestService
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
    checklistActions.append(.addFirstPasswordsManually)

    checklistActions.append(.activateAutofill)

    if session.configuration.info.accountType != .invisibleMasterPassword {
      checklistActions.append(.mobileToDesktop)
    }

    self.actions = checklistActions
    self.remainingActions = actions.filter { completionState(for: $0) == .todo }
  }

  var shouldShowOnboardingChecklist: Bool {
    let hasUserDismissedOnboardingChecklist =
      self.userSettings[.hasUserDismissedOnboardingChecklist] ?? false
    let hasUserUnlockedOnboardingChecklist =
      self.userSettings[.hasUserUnlockedOnboardingChecklist] ?? false

    return !hasUserDismissedOnboardingChecklist && hasUserUnlockedOnboardingChecklist
      && !Device.is(.mac)
  }

  var shouldShowAutofillDemo: Bool {
    let hasUserSeenAutoFillDemo = self.userSettings[.hasSeenAutofillDemo] ?? false
    return !hasUserSeenAutoFillDemo && isNewUser() && !Device.is(.mac)
  }

  func hasSeenAutofillDemo(_ value: Bool = true) {
    self.userSettings[.hasSeenAutofillDemo] = value
  }

  var hasCreatedAtLeastOneItem: Bool {
    self.userSettings[.hasCreatedAtLeastOneItem] ?? false
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
      loadingContext: SessionLoadingContext.localLogin(.regular(reportedLoginMode: .biometric)),
      accountType: .masterPassword,
      userSettings: UserSettings.mock,
      vaultItemsStore: MockVaultKitServicesContainer().vaultItemsStore,
      syncedSettings: SyncedSettingsService.mock,
      abTestService: ABTestingServiceMock.mock,
      lockService: LockServiceMock(),
      userSpacesService: UserSpacesService.mock(),
      featureService: .mock(),
      autofillService: AutofillStateService.fakeService
    )
  }
}
