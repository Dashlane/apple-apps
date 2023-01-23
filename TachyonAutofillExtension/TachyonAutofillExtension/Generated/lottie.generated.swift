import Foundation
import UIComponents

extension LottieAsset {
 internal static let passwordAddSuccess = LottieAsset(lightAppearanceFile: "Lottie/PasswordAddSuccess/PasswordAddSuccess_light.json", darkAppearanceFile: "Lottie/PasswordAddSuccess/PasswordAddSuccess_dark.json", bundle: BundleToken.bundle)
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
