import AppTrackingTransparency
import CoreCrypto
import CoreKeychain
import CoreTypes
import CoreUserTracking
import Foundation
import UIKit
import UserTrackingFoundation

#if canImport(AdSupport)
  import AdSupport
#endif
#if canImport(Adjust)
  import Adjust
#endif

extension UserTrackingAppActivityReporter {
  func trackInstall() {
    let isMarketingOptIn = ATTrackingManager.trackingAuthorizationStatus == .authorized
    let idfv = UIDevice.current.identifierForVendor?.uuidString
    #if canImport(Adjust) && canImport(AdSupport)
      let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString

      let event = UserEvent.FirstLaunch(
        ios: Definition.Ios(
          adid: Adjust.adid(),
          idfa: idfa,
          idfv: idfv
        ),
        isMarketingOptIn: isMarketingOptIn
      )
    #else
      let event = UserEvent.FirstLaunch(
        ios: Definition.Ios(idfv: idfv),
        isMarketingOptIn: isMarketingOptIn
      )
    #endif
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
