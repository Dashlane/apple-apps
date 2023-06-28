import Foundation
import Lottie
import UIKit
import UIComponents

extension DefaultAnimationCache {

            func preloadAnimationsForGuidedOnboarding() async {
        let animationAssets = GuidedOnboardingQuestion.allCases.map(\.animationAsset) + GuidedOnboardingAnswer.allCases.compactMap(\.animationAsset)
        await self.load(animationAssets)
    }
}
