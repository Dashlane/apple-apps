import Foundation
import StoreKit

class AdTracking {
  static func start() {
    #if !os(visionOS)
      SKAdNetwork.registerAppForAdNetworkAttribution()
    #endif
  }

  enum ConversionValue: Int {
    case accountCreation = 0
  }

  static func registerAccountCreation() {
    #if !os(visionOS)
      SKAdNetwork.updatePostbackConversionValue(ConversionValue.accountCreation.rawValue) { _ in }
    #endif
  }
}
