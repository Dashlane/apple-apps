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

extension SKAdNetwork {
  fileprivate enum ConversionValue: Int {
    case accountCreation = 0
  }

  fileprivate static func updateConversionValue(_ conversionValue: ConversionValue) {
    SKAdNetwork.updatePostbackConversionValue(conversionValue.rawValue) { _ in }
  }
}
