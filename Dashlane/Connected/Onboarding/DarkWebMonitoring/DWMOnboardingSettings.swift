import Combine
import CoreSettings
import Foundation

import struct DashTypes.Login

enum DWMOnboardingSettingsKey: String, CaseIterable, LocalSettingsKey {
  case progress
  case hasAddressedAllBreaches
  case hasGoneStraightToDWMOnboarding
  case hasSkippedDarkWebMonitoringOnboarding
  case darkWebMonitoringOnboardingCouldNotBeShown
  case hasSeenUnexpectedError
  case hasConfirmedEmailFromOnboardingChecklist
  case securedItemsIds
  case hasDismissedLastChanceScanPrompt
  case breachesMarkedAsViewed
  case registeredEmail

  var type: Any.Type {
    switch self {
    case .hasAddressedAllBreaches,
      .hasGoneStraightToDWMOnboarding,
      .hasSkippedDarkWebMonitoringOnboarding,
      .hasSeenUnexpectedError,
      .darkWebMonitoringOnboardingCouldNotBeShown,
      .hasConfirmedEmailFromOnboardingChecklist,
      .hasDismissedLastChanceScanPrompt,
      .breachesMarkedAsViewed:
      return Bool.self
    case .progress:
      return DWMOnboardingProgress.self
    case .securedItemsIds:
      return [String].self
    case .registeredEmail:
      return String.self
    }
  }

  var identifier: String {
    return rawValue
  }

  var isEncrypted: Bool {
    return false
  }
}

typealias DWMOnboardingSettings = KeyedSettings<DWMOnboardingSettingsKey>

extension DWMOnboardingSettings {
  func updateProgress(_ newValue: DWMOnboardingProgress) {
    let oldValue: DWMOnboardingProgress? = self[.progress]

    switch newValue {
    case .shown:
      guard oldValue == nil else {
        return
      }

      self[.progress] = DWMOnboardingProgress.shown
    case .emailRegistrationRequestSent, .emailConfirmed, .breachesNotFound, .breachesFound:
      updateIfSequential(newValue, oldValue: oldValue)
    }
  }

  private func updateIfSequential(
    _ newValue: DWMOnboardingProgress, oldValue: DWMOnboardingProgress?
  ) {
    guard (oldValue?.rawValue ?? 0) < newValue.rawValue else {
      return
    }

    self[.progress] = newValue
  }
}
