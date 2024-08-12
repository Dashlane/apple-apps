import CoreSettings
import Foundation

struct InMemoryUserSessionStore {

  private let settings: LocalSettingsStore
  private let container: SessionServicesContainer
  private let sessionCreationDate = Date.now.timeIntervalSince1970

  static var shared: InMemoryUserSessionStore?

  enum RetrieveSessionError: Swift.Error {
    case lockedOnExit
    case autoLockDelayReached
  }

  init(container: SessionServicesContainer) {
    self.settings = container.settings
    self.container = container
  }

  func retrieveStoredSession() throws -> SessionServicesContainer {

    guard !settings.shouldLockOnExit else {
      throw RetrieveSessionError.lockedOnExit
    }

    let delay = settings.autoLockDelay
    if delay > 0 && Date.now.timeIntervalSince1970 > (sessionCreationDate + delay) {
      throw RetrieveSessionError.autoLockDelayReached
    }

    return container
  }
}

extension LocalSettingsStore {
  var shouldLockOnExit: Bool {
    let lockSettings = keyed(by: UserLockSettingsKey.self)
    return lockSettings[.lockOnExit] ?? false
  }

  var autoLockDelay: TimeInterval {
    let lockSettings = keyed(by: UserLockSettingsKey.self)
    return lockSettings[.autoLockDelay] ?? 0
  }
}
