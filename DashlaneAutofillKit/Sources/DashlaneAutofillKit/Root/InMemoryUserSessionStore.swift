import CoreSettings
import CoreTypes
import Foundation
import LogFoundation

struct InMemoryUserSessionStore {

  private let settings: LocalSettingsStore
  private let container: SessionServicesContainer
  private let sessionCreationDate = Date.now.timeIntervalSince1970
  public var login: Login {
    container.session.login
  }

  static var shared: InMemoryUserSessionStore?

  @Loggable
  enum RetrieveSessionError: Swift.Error {
    case lockedOnExit
    case autoLockDelayReached
    case tooOld
  }

  init(container: SessionServicesContainer) {
    self.settings = container.settings
    self.container = container
  }

  func retrieveStoredSession() throws(RetrieveSessionError) -> SessionServicesContainer {
    guard !settings.shouldLockOnExit else {
      throw .lockedOnExit
    }

    let delay = settings.autoLockDelay
    if delay > 0 && Date.now.timeIntervalSince1970 > (sessionCreationDate + delay) {
      throw .autoLockDelayReached
    }

    return container
  }

  func retrieveStoredSessionIgnoringLock() throws(RetrieveSessionError) -> SessionServicesContainer
  {
    let delay: TimeInterval = 30
    if Date.now.timeIntervalSince1970 > (sessionCreationDate + delay) {
      throw .tooOld
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
