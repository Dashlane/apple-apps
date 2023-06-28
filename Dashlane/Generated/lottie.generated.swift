import Foundation
import UIComponents

extension LottieAsset {

 internal static let authenticator2faDemoAnimation = LottieAsset(file:"Lottie/authenticator_2fa_demo_animation.json", bundle: BundleToken.bundle)

 internal static let gradientLoading = LottieAsset(file:"Lottie/Gradient_Loading.json", bundle: BundleToken.bundle)

 internal static let guidedOnboarding01Autofill = LottieAsset(file:"Lottie/guidedOnboarding_01_autofill.json", bundle: BundleToken.bundle)

 internal static let guidedOnboarding02PwGenerator = LottieAsset(file:"Lottie/guidedOnboarding_02_pw_generator.json", bundle: BundleToken.bundle)

 internal static let guidedOnboarding03Breach = LottieAsset(file:"Lottie/guidedOnboarding_03_breach.json", bundle: BundleToken.bundle)

 internal static let guidedOnboarding04Onlinelife = LottieAsset(file:"Lottie/guidedOnboarding_04_onlinelife.json", bundle: BundleToken.bundle)

 internal static let guidedOnboarding05Vault = LottieAsset(file:"Lottie/guidedOnboarding_05_vault.json", bundle: BundleToken.bundle)

 internal static let guidedOnboarding06BouncingLogos = LottieAsset(file:"Lottie/guidedOnboarding_06_bouncing_logos.json", bundle: BundleToken.bundle)

 internal static let guidedOnboarding07Pwimport = LottieAsset(file:"Lottie/guidedOnboarding_07_pwimport.json", bundle: BundleToken.bundle)

 internal static let guidedOnboarding08Devices = LottieAsset(file:"Lottie/guidedOnboarding_08_devices.json", bundle: BundleToken.bundle)

 internal static let loadingAnimationCompletion = LottieAsset(file:"Lottie/loading_animation_completion.json", bundle: BundleToken.bundle)

 internal static let loadingAnimationFailure = LottieAsset(file:"Lottie/loading_animation_failure.json", bundle: BundleToken.bundle)

 internal static let loadingAnimationProgress = LottieAsset(file:"Lottie/loading_animation_progress.json", bundle: BundleToken.bundle)

 internal static let logo = LottieAsset(file:"Lottie/logo.json", bundle: BundleToken.bundle)

 internal static let onboardingAutofill = LottieAsset(file:"Lottie/onboarding_autofill.json", bundle: BundleToken.bundle)

 internal static let onboardingConfettis = LottieAsset(file:"Lottie/onboarding_confettis.json", bundle: BundleToken.bundle)

 internal static let onboardingM2d = LottieAsset(file:"Lottie/onboarding_m2d.json", bundle: BundleToken.bundle)

 internal static let onboardingVault = LottieAsset(file:"Lottie/onboarding_vault.json", bundle: BundleToken.bundle)

 internal static let onboardingVaultBackground = LottieAsset(file:"Lottie/onboarding_vault_background.json", bundle: BundleToken.bundle)

 internal static let passwordChangerLoading = LottieAsset(file:"Lottie/PasswordChanger_Loading.json", bundle: BundleToken.bundle)
 internal static let _2FAConfiguration = LottieAsset(lightAppearanceFile: "Lottie/2FAConfiguration/2FAConfiguration_light.json", darkAppearanceFile: "Lottie/2FAConfiguration/2FAConfiguration_dark.json", bundle: BundleToken.bundle)
 internal static let loading = LottieAsset(lightAppearanceFile: "Lottie/loading/loading_light.json", darkAppearanceFile: "Lottie/loading/loading_dark.json", bundle: BundleToken.bundle)
 internal static let loadingDeterminate = LottieAsset(lightAppearanceFile: "Lottie/loading_determinate/loading_determinate_light.json", darkAppearanceFile: "Lottie/loading_determinate/loading_determinate_dark.json", bundle: BundleToken.bundle)
 internal static let m2WChrome = LottieAsset(lightAppearanceFile: "Lottie/M2WChrome/M2WChrome_light.json", darkAppearanceFile: "Lottie/M2WChrome/M2WChrome_dark.json", bundle: BundleToken.bundle)
 internal static let m2WStartScreen = LottieAsset(lightAppearanceFile: "Lottie/M2WStartScreen/M2WStartScreen_light.json", darkAppearanceFile: "Lottie/M2WStartScreen/M2WStartScreen_dark.json", bundle: BundleToken.bundle)
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
