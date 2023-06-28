import Foundation
import CoreFeature
import Combine
import DashlaneAppKit
import SwiftTreats
import CoreSettings
import CorePersonalData
import DashTypes
import CoreSession
import VaultKit

class OnboardingService {
    private let loadingContext: SessionLoadingContext
    private let userSettings: UserSettings
    private let dwmOnboardingSettings: DWMOnboardingSettings
    private let syncedSettings: SyncedSettingsService
    private let abTestService: ABTestingServiceProtocol
    private let guidedOnboardingSettingsProvider: GuidedOnboardingSettingsProvider
    private let dwmOnboardingService: DWMOnboardingService
    private let lockService: LockServiceProtocol
    private let teamSpacesService: TeamSpacesService
    private let vaultItemsService: VaultItemsServiceProtocol
    private let featureService: FeatureServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private let accountType: AccountType

    private var isBiometricAuthenticationActivated: Bool {
        return lockService.secureLockConfigurator.isBiometricActivated
    }

    init(loadingContext: SessionLoadingContext,
         accountType: AccountType,
         userSettings: UserSettings,
         vaultItemsService: VaultItemsServiceProtocol,
         dwmOnboardingSettings: DWMOnboardingSettings,
         dwmOnboardingService: DWMOnboardingService,
         syncedSettings: SyncedSettingsService,
         abTestService: ABTestingServiceProtocol,
         lockService: LockServiceProtocol,
         teamSpacesService: TeamSpacesService,
         featureService: FeatureServiceProtocol) {
        self.loadingContext = loadingContext
        self.syncedSettings = syncedSettings
        self.userSettings = userSettings
        self.dwmOnboardingSettings = dwmOnboardingSettings
        self.dwmOnboardingService = dwmOnboardingService
        self.abTestService = abTestService
        self.guidedOnboardingSettingsProvider = GuidedOnboardingSettingsProvider(userSettings: userSettings)
        self.lockService = lockService
        self.teamSpacesService = teamSpacesService
        self.vaultItemsService = vaultItemsService
        self.featureService = featureService
        self.accountType = accountType

        unlockOnboardingIfRequired()
        setupSubscribers()
    }

    func setupSubscribers() {
        vaultItemsService
            .allItemsPublisher()
            .first { $0.count > 1 } 
            .sink { [weak self] _ in
                self?.userSettings[.hasCreatedAtLeastOneItem] = true
            }
            .store(in: &cancellables)
    }

    var shouldShowOnboardingChecklist: Bool {
        let hasUserDismissedOnboardingChecklist = self.userSettings[.hasUserDismissedOnboardingChecklist] ?? false
        let hasUserUnlockedOnboardingChecklist = self.userSettings[.hasUserUnlockedOnboardingChecklist] ?? false

        return !hasUserDismissedOnboardingChecklist && hasUserUnlockedOnboardingChecklist && !Device.isMac
    }

    var shouldShowAutofillDemo: Bool {
        let hasUserSeenAutoFillDemo = self.userSettings[.hasSeenAutofillDemo] ?? false
        return !hasUserSeenAutoFillDemo && isNewUser() && !Device.isMac
    }

    func shouldShowBrowsersExtensionsOnboarding() -> Bool {
        guard Device.isMac else { return false }
        skipSafariDisabledAnnouncementIfNeeded()
        let hasSeenBrowsersExtensionsOnboarding = userSettings[.hasSeenBrowsersExtensionsOnboarding] ?? false
        let hasSeenSafariDisabledOnboarding = userSettings[.hasSeenSafariDisabledOnboarding] ?? false
        return (!hasSeenBrowsersExtensionsOnboarding || shouldShowSafariDisabledOnboarding) && !hasSeenSafariDisabledOnboarding
    }

    var shouldShowSafariDisabledOnboarding: Bool {
        return featureService.isEnabled(.autofillSafariIsDisabled)
    }

    func hasSeenAutofillDemo(_ value: Bool = true) {
        self.userSettings[.hasSeenAutofillDemo] = value
    }

    func didSeeBrowsersExtensionsOnboarding() {
        userSettings[.hasSeenBrowsersExtensionsOnboarding] = true

        if featureService.isEnabled(.autofillSafariIsDisabled) {
            userSettings[.hasSeenSafariDisabledOnboarding] = true
        }
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
        let isSSOUser = teamSpacesService.isSSOUser
        let hasSeenOnboarding = userSettings[.hasSeenBiometricsOrPinOnboarding] == true
        let hasConvenientMethodSetup = lockService.secureLockProvider.secureLockMode() != .masterKey
        return isSSOUser && !hasSeenOnboarding && !hasConvenientMethodSetup
    }

        func isNewUser() -> Bool {
        guard let accountCreationDate = syncedSettings[\.accountCreationDatetime] else {
                                    return false
        }

        guard let numberOfDaysSinceAccountCreation = Date().numberOfDays(since: accountCreationDate) else {
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

    func skipSafariDisabledAnnouncementIfNeeded() {
        guard Device.isMac else { return }
        guard loadingContext.isFirstLogin else {
            return
        }
                        if featureService.isEnabled(.autofillSafariIsDisabled) {
            userSettings[.hasSeenSafariDisabledOnboarding] = true
        }
    }
}

 extension OnboardingService {
    static var mock: OnboardingService {
        .init(
            loadingContext: SessionLoadingContext.localLogin(),
            accountType: .masterPassword,
            userSettings: UserSettings.mock,
            vaultItemsService: MockServicesContainer().vaultItemsService,
            dwmOnboardingSettings: DWMOnboardingSettings(internalStore: .mock()),
            dwmOnboardingService: DWMOnboardingService.mock,
            syncedSettings: SyncedSettingsService.mock,
            abTestService: ABTestingServiceMock.mock,
            lockService: LockServiceMock(),
            teamSpacesService: TeamSpacesService.mock(),
            featureService: .mock()
        )
    }
 }
