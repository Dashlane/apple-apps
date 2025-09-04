import CoreSession
import CoreSettings
import CoreTypes
import Foundation

protocol M2WSettingsProvider {
  func hasUserFinishedM2W() -> Bool
  func setUserHasFinishedM2W()
}

class M2WSettings: M2WSettingsProvider, SessionServicesInjecting {
  private let userSettings: UserSettings

  init(userSettings: UserSettings) {
    self.userSettings = userSettings
  }

  func hasUserFinishedM2W() -> Bool {
    guard let hasFinished: Bool = userSettings[.m2wDidFinishOnce] else {
      return false
    }
    return hasFinished
  }

  func setUserHasFinishedM2W() {
    userSettings[.m2wDidFinishOnce] = true
  }
}
