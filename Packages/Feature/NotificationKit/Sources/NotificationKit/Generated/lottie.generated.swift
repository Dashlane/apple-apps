import Foundation
import UIComponents

extension LottieAsset {

 internal static let autofillBannerTutorial = LottieAsset(file:"autofill_banner_tutorial.json", bundle: BundleToken.bundle)

 internal static let diamond = LottieAsset(file:"diamond.json", bundle: BundleToken.bundle)
}
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
