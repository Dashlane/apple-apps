import Foundation
import UIComponents

extension LottieAsset {

 internal static let passwordChangerLoading = LottieAsset(file:"Lottie/PasswordChanger_Loading.json", bundle: BundleToken.bundle)
 internal static let loading = LottieAsset(lightAppearanceFile: "Lottie/loading/loading_light.json", darkAppearanceFile: "Lottie/loading/loading_dark.json", bundle: BundleToken.bundle)
 internal static let passwordChangerFail = LottieAsset(lightAppearanceFile: "Lottie/PasswordChangerFail/PasswordChangerFail_light.json", darkAppearanceFile: "Lottie/PasswordChangerFail/PasswordChangerFail_dark.json", bundle: BundleToken.bundle)
 internal static let passwordChangerSuccess = LottieAsset(lightAppearanceFile: "Lottie/PasswordChangerSuccess/PasswordChangerSuccess_light.json", darkAppearanceFile: "Lottie/PasswordChangerSuccess/PasswordChangerSuccess_dark.json", bundle: BundleToken.bundle)
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
