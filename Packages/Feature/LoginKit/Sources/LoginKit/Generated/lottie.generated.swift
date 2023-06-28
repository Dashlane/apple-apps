import Foundation
import UIComponents

extension LottieAsset {

 internal static let passwordChangerLoading = LottieAsset(file:"PasswordChanger_Loading.json", bundle: BundleToken.bundle)

 internal static let preOnboardingAutofillScreenLoop = LottieAsset(file:"pre_onboarding_autofillScreen_loop.json", bundle: BundleToken.bundle)

 internal static let preOnboardingSecurityAlertsScreenLoop = LottieAsset(file:"pre_onboarding_securityAlertsScreen_loop.json", bundle: BundleToken.bundle)

 internal static let preOnboardingTrustScreenTransition = LottieAsset(file:"pre_onboarding_trustScreen_transition.json", bundle: BundleToken.bundle)

 internal static let preOnboardingVaultScreenLoop = LottieAsset(file:"pre_onboarding_vaultScreen_loop.json", bundle: BundleToken.bundle)

 internal static let preOnboardingVaultScreenTransition = LottieAsset(file:"pre_onboarding_vaultScreen_transition.json", bundle: BundleToken.bundle)
 internal static let loading = LottieAsset(lightAppearanceFile: "loading_light.json", darkAppearanceFile: "loading_dark.json", bundle: BundleToken.bundle)
 internal static let passwordChangerFail = LottieAsset(lightAppearanceFile: "PasswordChangerFail_light.json", darkAppearanceFile: "PasswordChangerFail_dark.json", bundle: BundleToken.bundle)
 internal static let passwordChangerSuccess = LottieAsset(lightAppearanceFile: "PasswordChangerSuccess_light.json", darkAppearanceFile: "PasswordChangerSuccess_dark.json", bundle: BundleToken.bundle)
 internal static let preOnboardingAuthenticatorLoop = LottieAsset(lightAppearanceFile: "pre_onboarding_authenticator_loop_light.json", darkAppearanceFile: "pre_onboarding_authenticator_loop_dark.json", bundle: BundleToken.bundle)
 internal static let preOnboardingPrivacyScreenLoop = LottieAsset(lightAppearanceFile: "pre_onboarding_privacyScreen_loop_light.json", darkAppearanceFile: "pre_onboarding_privacyScreen_loop_dark.json", bundle: BundleToken.bundle)
 internal static let preOnboardingTrustScreenLoop = LottieAsset(lightAppearanceFile: "pre_onboarding_trustScreen_loop_light.json", darkAppearanceFile: "pre_onboarding_trustScreen_loop_dark.json", bundle: BundleToken.bundle)
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
