import CoreKeychain
import CoreSession
import DashTypes
import Foundation

public struct SessionCleaner: SessionCleanerProtocol {
  let keychainService: AuthenticationKeychainServiceProtocol
  let sessionsContainer: SessionsContainerProtocol
  let logger: Logger
  let fileManager = FileManager.default

  public init(
    keychainService: AuthenticationKeychainServiceProtocol,
    sessionsContainer: SessionsContainerProtocol,
    logger: Logger
  ) {
    self.keychainService = keychainService
    self.sessionsContainer = sessionsContainer
    self.logger = logger
  }

  public func removeLocalData(for login: Login) {
    do {
      try? keychainService.removeMasterKey(for: login)
      try sessionsContainer.removeSessionDirectory(for: login)
      try sessionsContainer.saveCurrentLogin(nil)
    } catch {
      logger.fatal("Failed to delete session data after invalidation", error: error)
    }
  }

  public func cleanAutoLoginData(for login: Login) {
    try? sessionsContainer.saveCurrentLogin(nil)
    try? keychainService.removeMasterKey(for: login)
  }
}
