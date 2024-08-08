import Combine
import DashTypes
import Foundation

public enum UserSettingsKey: String, CaseIterable, LocalSettingsKey {
  case hiddenTeamSpaces = "HIDDEN_TEAM_SPACES"
  case advancedSystemIntegration = "KW_ADVANCED_IOS_INTEGRATION"
  case clipboardExpirationDelay = "clipboardExpirationDelay"
  case isUniversalClipboardEnabled = "isUniversalClipboardEnabled"
  case clipboardOverrideEnabled = "CLIPBOARD_OVERRIDE_ENABLED"
  case hasSeenSecureWifiOnboarding
  case resetMasterPasswordWithBiometricsReactivationNeeded =
    "ResetMasterPasswordWithBiometricsReactivationNeeded"
  case deviceTokenForRemoteNotifications
  case guidedOnboardingData
  case hasSkippedGuidedOnboarding
  case hasSkippedPasswordOnboarding
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
  case fastLocalSetupForRemoteLoginDisplayed
  case hasUsedPasswordChanger
  case automaticallyLoggedOut
  case hasSeenDWMExperience
  case trialStartedHasBeenShown
  case lastpassImportPopupHasBeenShown
  case autofillActivationPopUpHasBeenShown
  case abTestingCache = "abTestingCenterCurrentTestsStoredKey"
  case planRecommandationHasBeenShown
  case hasCreatedAtLeastOneItem
  case hasDismissedNewVPNProviderMessage
  case hasDismissedAuthenticatorSunsetBanner
  case ssoAuthenticationRequested
  case lastAggregatedLogsUploadDate
  case premiumExpirationSentNotifications

  public var type: Any.Type {
    switch self {
    case .advancedSystemIntegration,
      .isUniversalClipboardEnabled,
      .hasSeenSecureWifiOnboarding,
      .clipboardOverrideEnabled,
      .resetMasterPasswordWithBiometricsReactivationNeeded,
      .hasSkippedGuidedOnboarding,
      .hasSkippedPasswordOnboarding,
      .m2wDidFinishOnce,
      .chromeImportDidFinishOnce,
      .hasUserUnlockedOnboardingChecklist,
      .hasUserDismissedOnboardingChecklist,
      .hasSeenAutofillDemo,
      .hasSeenBiometricsOrPinOnboarding,
      .rateAppDidDisplay,
      .fastLocalSetupForRemoteLoginDisplayed,
      .hasUsedPasswordChanger,
      .automaticallyLoggedOut,
      .hasSeenDWMExperience,
      .trialStartedHasBeenShown,
      .lastpassImportPopupHasBeenShown,
      .autofillActivationPopUpHasBeenShown,
      .planRecommandationHasBeenShown,
      .hasCreatedAtLeastOneItem,
      .hasDismissedNewVPNProviderMessage,
      .hasDismissedAuthenticatorSunsetBanner,
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
      .rateAppLastDisplayedDate,
      .lastAggregatedLogsUploadDate:
      return Date.self
    case .hiddenTeamSpaces:
      return [String].self
    case .clipboardExpirationDelay:
      return TimeInterval.self
    case .guidedOnboardingData:
      return [GuidedOnboardingSettingsData].self
    case .rateAppDeclineResponseCount:
      return Int.self
    case .passwordGeneratorPreferences:
      return PasswordGeneratorPreferences.self
    case .premiumExpirationSentNotifications:
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

extension KeyedSettings where Key == UserSettingsKey {
  public static var mock: UserSettings {
    .init(internalStore: .mock())
  }
}
