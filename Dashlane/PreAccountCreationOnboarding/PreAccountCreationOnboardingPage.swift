import Foundation
import AVKit
import Lottie
import DashlaneAppKit
import SwiftTreats
import UIComponents

final class PreAccountCreationOnboardingPage: UIViewController {

    struct Content {
        let transitionAnimation: LottieAsset?
        let loopAnimation: LottieAsset
        let titleLocalizationKey: String
        let descriptionLocalizationKey: String
        let isLoopAnimationOnTop: Bool
    }

        var content: Content!
    var loopAnimationView: LottieAnimationView!
    var transitionAnimationView: LottieAnimationView?

        @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    static func instantiate(with content: Content) -> PreAccountCreationOnboardingPage {
        let currentBundle = Bundle(for: PreAccountCreationOnboardingPage.self)
        let storyboard = Device.isIpadOrMac
            ? UIStoryboard(name: "PreAccountCreationOnboardingiPad", bundle: currentBundle)
            : UIStoryboard(name: "PreAccountCreationOnboarding", bundle: currentBundle)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "PreAccountCreationOnboardingPage") as? PreAccountCreationOnboardingPage else {
            fatalError("Unable to instatiate PreAccountCreationOnboardingPage")
        }
        controller.content = content

        return controller
    }

        override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = NSLocalizedString(content.titleLocalizationKey, comment: "")
        self.descriptionLabel.text = NSLocalizedString(content.descriptionLocalizationKey, comment: "")

        applyStyle()
        updateAnimations()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

                guard traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else {
            return
        }

        updateAnimations()
    }
}

private extension PreAccountCreationOnboardingPage {
    func applyStyle() {
        titleLabel.font = DashlaneFont.custom(26.0, .bold).uiFont
        titleLabel.textColor = FiberAsset.mainCopy.color

        descriptionLabel.textColor = FiberAsset.placeholder.color
    }
}

private extension PreAccountCreationOnboardingPage {

    func updateAnimations() {
        if content.transitionAnimation != nil {
            if content.isLoopAnimationOnTop {
                setTransitionAnimation()
                setLoopAnimation()
            } else {
                setLoopAnimation()
                setTransitionAnimation()
            }
        } else {
            setLoopAnimation()
        }
    }

    func setTransitionAnimation() {
        guard let transitionAnimation = content.transitionAnimation?.animation() else { return }

        transitionAnimationView?.removeFromSuperview()
        transitionAnimationView = LottieAnimationView(animation: transitionAnimation)
        transitionAnimationView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        transitionAnimationView?.contentMode = .scaleAspectFit
        transitionAnimationView?.frame = animationView.bounds
        transitionAnimationView?.loopMode = .loop
        transitionAnimationView?.currentProgress = 0.5

        if let transitionAnimationView = transitionAnimationView { self.animationView.addSubview(transitionAnimationView) }
    }

    func setLoopAnimation() {
        let loopAnimation = content.loopAnimation.animation()
        loopAnimationView?.stop()
        loopAnimationView?.removeFromSuperview()
        loopAnimationView = LottieAnimationView(animation: loopAnimation)
        loopAnimationView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        loopAnimationView.contentMode = .scaleAspectFit
        loopAnimationView.frame = animationView.bounds
        loopAnimationView.loopMode = .loop

        self.animationView.addSubview(loopAnimationView)
        loopAnimationView.play()

    }
}
