import Foundation
import AppTrackingTransparency
import CoreFeature
import Adjust
import DashTypes
import SwiftTreats

class AppTrackingTransparencyService {

    private let authenticatedABTestingService: AuthenticatedABTestingService
    private let appTrackingTransparencyLogger: AppTrackingTransparencyLogger
    private let logger: Logger

    init(authenticatedABTestingService: AuthenticatedABTestingService, appTrackingTransparencyLogger: AppTrackingTransparencyLogger, logger: Logger) {
        self.authenticatedABTestingService = authenticatedABTestingService
        self.appTrackingTransparencyLogger = appTrackingTransparencyLogger
        self.logger = logger
    }

    func requestAuthorization() {
        #if DEBUG
        guard !ProcessInfo.isTesting else {
            return
        }
        #endif

        appTrackingTransparencyLogger.log(.authorizationRequested)

        ATTrackingManager.requestTrackingAuthorization { [weak self] status in
            switch status {
            case .authorized:
                self?.appTrackingTransparencyLogger.log(.authorized)
            case .denied:
                self?.appTrackingTransparencyLogger.log(.denied)
            case .restricted:
                self?.appTrackingTransparencyLogger.log(.restricted)
            case .notDetermined:
                self?.appTrackingTransparencyLogger.log(.undetermined)
            @unknown default:
                self?.logger.fatal("Unknown authorization status \(status).")
                return
            }

                                                Adjust.requestTrackingAuthorization(completionHandler: nil)
        }
    }

}
