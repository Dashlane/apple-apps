import CoreSession
import Foundation
import LoginKit

extension AppServicesContainer {
  var sessionCleaner: SessionCleanerProtocol {
    SessionCleaner(
      keychainService: keychainService, sessionsContainer: sessionContainer,
      logger: rootLogger[.session])
  }
}
