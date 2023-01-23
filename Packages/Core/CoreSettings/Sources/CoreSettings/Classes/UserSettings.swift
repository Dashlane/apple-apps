import Foundation
import DashTypes
import struct DashTypes.Login
import Combine

public enum UserSettingsKey: String, CaseIterable, LocalSettingsKey {
        case hiddenTeamSpaces = "HIDDEN_TEAM_SPACES"
    case advancedSystemIntegration = "KW_ADVANCED_IOS_INTEGRATION"
    case clipboardExpirationDelay = "clipboardExpirationDelay"
    case isUniversalClipboardEnabled = "isUniversalClipboardEnabled"
    case clipboardOverrideEnabled = "CLIPBOARD_OVERRIDE_ENABLED"
    case hasSeenSecureWifiOnboarding
    case resetMasterPasswordWithBiometricsReactivationNeeded = "ResetMasterPasswordWithBiometricsReactivationNeeded"
    case vaultItemSorting
    case deviceTokenForRemoteNotifications
    case guidedOnboardingData
    case hasSkippedGuidedOnboarding
    case m2wDidFinishOnce
        case publicUserId
    case chromeImportDidFinishOnce
    case hasUserUnlockedOnboardingChecklist
    case hasUserDismissedOnboardingChecklist
    case hasSeenAutofillDemo
    case hasSeenBiometricsOrPinOnboarding
    case rateAppDeclineResponseCount
    case rateApplastOneOffBlast
    case rateAppInstallDate
    case rateAppLastVersion
    case rateAppLastDisplayedDate
    case rateAppDidDisplay
    case passwordGeneratorPreferences
    case hasSentDeduplicationAudit
    case fastLocalSetupForRemoteLoginDisplayed
    case hasUsedPasswordChanger
    case automaticallyLoggedOut
    case hasSeenDWMExperience
    case safariIsSaveCredentialDisabled
    case trialStartedHasBeenShown
    case autofillActivationPopUpHasBeenShown
    case hasSeenBrowsersExtensionsOnboarding
    case hasSeenSafariDisabledOnboarding
    case abTestingCache = "abTestingCenterCurrentTestsStoredKey"
    case planRecommandationHasBeenShown
    case hasCreatedAtLeastOneItem
    case hasDismissedNewVPNProviderMessage
    case ssoAuthenticationRequested

    public var type: Any.Type {
        switch self {
        case .advancedSystemIntegration,
             .isUniversalClipboardEnabled,
             .hasSeenSecureWifiOnboarding,
             .clipboardOverrideEnabled,
             .resetMasterPasswordWithBiometricsReactivationNeeded,
             .hasSkippedGuidedOnboarding,
             .m2wDidFinishOnce,
             .chromeImportDidFinishOnce,
             .hasUserUnlockedOnboardingChecklist,
             .hasUserDismissedOnboardingChecklist,
             .hasSeenAutofillDemo,
             .hasSeenBiometricsOrPinOnboarding,
             .rateAppDidDisplay,
             .hasSentDeduplicationAudit,
             .fastLocalSetupForRemoteLoginDisplayed,
             .hasUsedPasswordChanger,
             .automaticallyLoggedOut,
             .hasSeenDWMExperience,
             .trialStartedHasBeenShown,
             .autofillActivationPopUpHasBeenShown,
             .hasSeenBrowsersExtensionsOnboarding,
             .hasSeenSafariDisabledOnboarding,
             .planRecommandationHasBeenShown,
             .hasCreatedAtLeastOneItem,
             .hasDismissedNewVPNProviderMessage,
             .ssoAuthenticationRequested:
            return Bool.self
        case .deviceTokenForRemoteNotifications,
             .abTestingCache:
            return Data.self
        case .publicUserId,
             .rateApplastOneOffBlast,
             .rateAppLastVersion:
            return String.self
        case .rateAppInstallDate,
            .rateAppLastDisplayedDate:
            return Date.self
        case .hiddenTeamSpaces:
            return [String].self
        case .clipboardExpirationDelay:
            return TimeInterval.self
        case .vaultItemSorting:
            return VaultItemSorting.self
        case .guidedOnboardingData:
            return [GuidedOnboardingSettingsData].self
        case .rateAppDeclineResponseCount:
            return Int.self
        case .passwordGeneratorPreferences:
            return PasswordGeneratorPreferences.self
        case .safariIsSaveCredentialDisabled:
            return Set<String>.self
        }
    }
}

public typealias UserSettings = KeyedSettings<UserSettingsKey>

extension LocalSettingsFactory {
        public func fetchOrCreateUserSettings(for login: Login) throws -> UserSettings {
        let settings = try fetchOrCreateSettings(for: login)
        let userSettings = settings.keyed(by: UserSettingsKey.self)
        return userSettings
    }
}

public extension KeyedSettings where Key == UserSettingsKey {
    static var mock: UserSettings {
        .init(internalStore: InMemoryLocalSettingsStore())
    }
}
