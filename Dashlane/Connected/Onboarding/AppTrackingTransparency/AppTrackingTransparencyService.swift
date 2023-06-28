import Foundation
import AppTrackingTransparency
import CoreFeature
import Adjust
import DashTypes
import SwiftTreats

class AppTrackingTransparencyService {

    private let authenticatedABTestingService: AuthenticatedABTestingService
    private let logger: Logger

    init(authenticatedABTestingService: AuthenticatedABTestingService, logger: Logger) {
        self.authenticatedABTestingService = authenticatedABTestingService
        self.logger = logger
    }

    func requestAuthorization() {
        #if DEBUG
        guard !ProcessInfo.isTesting else {
            return
        }
        #endif

        ATTrackingManager.requestTrackingAuthorization { _ in
                                                Adjust.requestTrackingAuthorization(completionHandler: nil)
        }
    }

}
