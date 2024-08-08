import Foundation
import Lottie
import UIComponents
import UIKit

extension DefaultAnimationCache {

  func preloadAnimationsForGuidedOnboarding() async {
    let animationAssets =
      GuidedOnboardingQuestion.allCases.map(\.animationAsset)
      + GuidedOnboardingAnswer.allCases.compactMap(\.animationAsset)
    await self.load(animationAssets)
  }
}
