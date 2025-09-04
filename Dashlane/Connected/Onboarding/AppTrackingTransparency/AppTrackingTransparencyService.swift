import AppTrackingTransparency
import CoreFeature
import CoreTypes
import Foundation
import LogFoundation
import SwiftTreats

#if canImport(Adjust)
  import Adjust
#endif

struct AppTrackingTransparencyService {
  private let logger: Logger

  init(logger: Logger) {
    self.logger = logger
  }

  func requestAuthorization() async {
    #if DEBUG
      guard !ProcessInfo.isTesting else {
        return
      }
    #endif

    let status = await ATTrackingManager.requestTrackingAuthorization()
    logger.info("ATTrackingManager status: \(status)")
    #if canImport(Adjust)
      await Adjust.requestTrackingAuthorization()
    #endif
  }
}
