import Foundation
import CoreUserTracking
import Adjust
import UIKit
import AppTrackingTransparency
import AdSupport

extension UserTrackingAppActivityReporter {
    func trackInstall() {
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        let idfv = UIDevice.current.identifierForVendor?.uuidString
        let isMarketingOptIn = ATTrackingManager.trackingAuthorizationStatus == .authorized

        let event = UserEvent.FirstLaunch(ios: Definition.Ios(
            adid: Adjust.adid(),
            idfa: idfa,
            idfv: idfv),
                                          isMarketingOptIn: isMarketingOptIn)
        report(event)
    }
}
