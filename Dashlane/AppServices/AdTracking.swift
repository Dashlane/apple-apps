import Foundation
import StoreKit

class AdTracking {
        static func start() {
        SKAdNetwork.registerAppForAdNetworkAttribution()
    }

        static func registerAccountCreation() {
        SKAdNetwork.updateConversionValue(.accountCreation)
    }
}

private extension SKAdNetwork {
        enum ConversionValue: Int {
        case accountCreation = 0
    }

        static func updateConversionValue(_ conversionValue: ConversionValue) {
        SKAdNetwork.updatePostbackConversionValue(conversionValue.rawValue) {_ in }
    }
}
