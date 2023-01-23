import Foundation
import Lottie
import UIKit
import UIComponents

extension LottieAnimation {

            static func preloadAnimationsForGuidedOnboarding() {
        let animationAssets = GuidedOnboardingQuestion.allCases.map(\.animationAsset) + GuidedOnboardingAnswer.allCases.compactMap(\.animationAsset)
        animationAssets.preloadInBackground()
    }
}
