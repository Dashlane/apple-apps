import Foundation
import UIComponents

enum GuidedOnboardingQuestion: Int, CaseIterable, Hashable, Equatable {
    case whyDashlane = 0
    case howPasswordsHandled = 1

    var title: String {
        switch self {
        case .whyDashlane:
            return L10n.Localizable.guidedOnboardingWhyDashlaneTitle
        case .howPasswordsHandled:
            return L10n.Localizable.guidedOnboardingHowTitle
        }
    }

    var description: String {
        switch self {
        case .whyDashlane:
            return L10n.Localizable.guidedOnboardingWhyDashlaneDescription
        case .howPasswordsHandled:
            return L10n.Localizable.guidedOnboardingHowDescription
        }
    }

    var animationAsset: LottieAsset {
        switch self {
        case .whyDashlane:
            return .guidedOnboarding04Onlinelife
        case .howPasswordsHandled:
            return .guidedOnboarding06BouncingLogos
        }
    }
}
