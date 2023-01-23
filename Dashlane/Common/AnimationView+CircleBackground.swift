import Foundation
import UIComponents
import Lottie
import UIKit

enum LottieAnimationViewKeypath: String {
    case identityDashboardCircle = "load 2.Ellipse 1.Stroke 1.Color"
}

extension LottieAnimationView {
    func addCircleBackground(to keypath: LottieAnimationViewKeypath, isDarkMode: Bool = false) {
        let backgroundKeyPath = AnimationKeypath(keypath: keypath.rawValue)
        var colorProvider: ColorValueProvider

        if isDarkMode {
            colorProvider = ColorValueProvider(UIColor.white.lottieColorValue)
        } else {
            colorProvider = ColorValueProvider(UIColor.black.lottieColorValue)
        }

        self.setValueProvider(colorProvider, keypath: backgroundKeyPath)
    }
}
