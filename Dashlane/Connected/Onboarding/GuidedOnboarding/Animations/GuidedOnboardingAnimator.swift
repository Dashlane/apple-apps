import DesignSystem
import UIKit

class GuidedOnboardingAnimator: NSObject, UIViewControllerAnimatedTransitioning {

  private let duration = 1.0
  private let imageView: UIImageView = {
    let image = FiberAsset.guidedOnboardingLogoMark.image.withRenderingMode(.alwaysTemplate)
    let imageView = UIImageView(image: image)
    imageView.tintColor = .ds.background.default
    imageView.contentMode = .scaleAspectFill
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?)
    -> TimeInterval
  {
    return duration
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let containerView = transitionContext.containerView
    let toView = transitionContext.view(forKey: .to)!
    let fromView = transitionContext.view(forKey: .from)!

    let imageViewOffset: CGFloat = 180.0
    containerView.addSubview(toView)
    containerView.addSubview(imageView)
    containerView.addSubview(fromView)
    NSLayoutConstraint.activate([
      imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: -12),
      imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 12),
      imageView.topAnchor.constraint(equalTo: fromView.bottomAnchor, constant: -imageViewOffset),
    ])

    UIView.animate(
      withDuration: duration,
      animations: {
        fromView.frame.origin.y = -fromView.frame.size.height - imageViewOffset
        self.imageView.frame.origin.y = -fromView.frame.size.height - imageViewOffset
      },
      completion: { _ in
        transitionContext.completeTransition(true)
      }
    )
  }
}
