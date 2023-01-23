import Foundation
import UIComponents

extension LottieAsset {

 internal static let passwordChangerLoading = LottieAsset(file:"Lottie/PasswordChanger_Loading.json", bundle: BundleToken.bundle)

 internal static let success = LottieAsset(file:"Lottie/success.json", bundle: BundleToken.bundle)
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
