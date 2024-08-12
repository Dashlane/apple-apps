import AdSupport
import Adjust
import AppTrackingTransparency
import CoreCrypto
import CoreKeychain
import CoreUserTracking
import DashTypes
import Foundation
import UIKit

extension UserTrackingAppActivityReporter {
  func trackInstall() {
    let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
    let idfv = UIDevice.current.identifierForVendor?.uuidString
    let isMarketingOptIn = ATTrackingManager.trackingAuthorizationStatus == .authorized

    let event = UserEvent.FirstLaunch(
      ios: Definition.Ios(
        adid: Adjust.adid(),
        idfa: idfa,
        idfv: idfv
      ),
      isMarketingOptIn: isMarketingOptIn
    )
    report(event)
  }
}

public struct UserTrackingAppActivityReporterCryptoEngine:
  UserTrackingAppActivityReporterCryptoEngineProvider
{
  public func trackingDataCryptoEngine(forKey data: Data) throws -> CryptoEngine {
    try CryptoConfiguration.legacy(.kwc5).makeCryptoEngine(secret: .key(data))
  }
}
