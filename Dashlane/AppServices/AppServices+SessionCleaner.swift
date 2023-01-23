import Foundation
import LoginKit

extension AppServicesContainer {
    var sessionCleaner: SessionCleaner {
        SessionCleaner(keychainService: keychainService, sessionsContainer: sessionContainer, logger: rootLogger[.session])
    }
}
