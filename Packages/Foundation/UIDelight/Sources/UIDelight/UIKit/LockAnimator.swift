#if canImport(UIKit)
  import UIKit

  public class LockAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private static let slideMargin: CGFloat = 100
    private static let fadeRatio: TimeInterval = 5
    private static let duration: TimeInterval = 0.55

    static let cleftViewTag = 17347

    public init(isOpening: Bool, cleftView: UIView? = nil) {
      self.isOpening = isOpening
      self.cleftView = cleftView
    }

    let isOpening: Bool
    var cleftView: UIView?

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?)
      -> TimeInterval
    {
      return Self.duration
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
      guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from),
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)
      else {
        transitionContext.completeTransition(true)
        return
      }

      toView.frame = transitionContext.containerView.bounds

      let behindView = isOpening ? toView : fromView
      let frontView = isOpening ? fromView : toView

      transitionContext.containerView.insertSubview(toView, belowSubview: fromView)
      toView.layoutIfNeeded()

      let cleftView = frontView.viewWithTag(Self.cleftViewTag) ?? frontView
      let cleftFrame = transitionContext.containerView.convert(cleftView.bounds, from: cleftView)

      let (topFrame, bottomFrame) = transitionContext.containerView.bounds.divided(
        atDistance: cleftFrame.midY, from: .minYEdge)
      let frontSnapshotTop = makeFrontSnapshotView(from: frontView, byCroppingWith: topFrame)
      let frontSnapshotBottom = makeFrontSnapshotView(from: frontView, byCroppingWith: bottomFrame)

      let shadowViewTop = makeShadowView(withFrame: topFrame)
      shadowViewTop.layer.shadowOffset = CGSize(width: 0, height: 3)
      let shadowViewBottom = makeShadowView(withFrame: bottomFrame)
      shadowViewBottom.layer.shadowOffset = CGSize(width: 0, height: -3)

      let animationViews = [shadowViewTop, shadowViewBottom, frontSnapshotTop, frontSnapshotBottom]

      animationViews.forEach {
        transitionContext.containerView.addSubview($0)
      }

      frontView.alpha = 0

      CATransaction.begin()

      CATransaction.setCompletionBlock({
        fromView.layer.removeAllAnimations()
        fromView.removeFromSuperview()
        animationViews.forEach {
          $0.removeFromSuperview()
        }
        frontView.alpha = 1
        transitionContext.completeTransition(true)
        toView.layer.removeAllAnimations()
      })
      CATransaction.setAnimationDuration(Self.duration)

      let slideTopAnim = makeSlideAnimation(forFrame: topFrame, direction: .top)
      let slideBottomAnim = makeSlideAnimation(forFrame: bottomFrame, direction: .bottom)

      frontSnapshotTop.layer.add(slideTopAnim, forKey: "slide")
      frontSnapshotBottom.layer.add(slideBottomAnim, forKey: "slide")
      shadowViewTop.layer.add(slideTopAnim, forKey: "slide")
      shadowViewBottom.layer.add(slideBottomAnim, forKey: "slide")

      let shadowAnim = CABasicAnimation(keyPath: "shadowRadius")
      shadowAnim.fillMode = .both
      shadowAnim.isRemovedOnCompletion = false
      if isOpening {
        shadowAnim.toValue = 1
      } else {
        shadowAnim.fromValue = 1
      }
      shadowViewTop.layer.add(shadowAnim, forKey: "shadowRadius")
      shadowViewBottom.layer.add(shadowAnim, forKey: "shadowRadius")

      let shadowAnimOffset = CABasicAnimation(keyPath: "shadowOffset")
      shadowAnimOffset.fillMode = .both
      shadowAnimOffset.isRemovedOnCompletion = false
      if isOpening {
        shadowAnimOffset.toValue = NSValue(cgSize: .zero)
      } else {
        shadowAnimOffset.fromValue = NSValue(cgSize: .zero)
      }
      shadowViewTop.layer.add(shadowAnimOffset, forKey: "shadowOffset")
      shadowViewBottom.layer.add(shadowAnimOffset, forKey: "shadowOffset")

      let fadeAnim = CABasicAnimation(keyPath: "opacity")
      fadeAnim.duration = Self.duration / Self.fadeRatio
      fadeAnim.fillMode = CAMediaTimingFillMode.both
      fadeAnim.timingFunction = CAMediaTimingFunction(name: isOpening ? .easeIn : .easeOut)
      fadeAnim.isRemovedOnCompletion = true
      if isOpening {
        fadeAnim.toValue = 0
      } else {
        fadeAnim.fromValue = 0

      }
      let delay = isOpening ? ((Self.fadeRatio - 1.0) * Self.duration / Self.fadeRatio) : 0
      let fadeAnimDelayed = fadeAnim.delayed(by: delay)
      animationViews.forEach {
        $0.layer.add(fadeAnimDelayed, forKey: "opacity")
      }

      let scale: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
      if isOpening {
        scale.fromValue = 0.9
      } else {
        scale.toValue = 0.9
        scale.isRemovedOnCompletion = false

      }
      scale.timingFunction = CAMediaTimingFunction(name: .easeIn)
      scale.duration = 2.0 / 3.0 * Self.duration
      scale.fillMode = .both
      let delayedScale = isOpening ? scale.delayed(by: Self.duration - scale.duration) : scale
      behindView.layer.add(delayedScale, forKey: "scale")

      CATransaction.commit()
    }

    public func animationEnded(transitionCompleted: Bool) {

    }
  }

  extension LockAnimator {
    private func makeShadowView(withFrame frame: CGRect) -> UIView {
      let shadowView = UIView(frame: frame)
      shadowView.layer.shadowRadius = 20
      shadowView.layer.shadowOpacity = 0.5
      shadowView.layer.shadowPath = UIBezierPath(rect: shadowView.layer.bounds).cgPath
      return shadowView
    }

    private func makeFrontSnapshotView(from sourceView: UIView, byCroppingWith frame: CGRect)
      -> UIView
    {
      let frontSnapshotContainer = UIView(frame: frame)
      if let frontSnapshot = sourceView.snapshotView(afterScreenUpdates: true) {
        frontSnapshotContainer.addSubview(frontSnapshot)
      }
      frontSnapshotContainer.clipsToBounds = true
      frontSnapshotContainer.bounds = frame
      return frontSnapshotContainer
    }

    private func makeSlideAnimation(forFrame frame: CGRect, direction: CAAnimation.SlideDirection)
      -> CAAnimation
    {
      let containerSize = CGSize(
        width: frame.size.width, height: frame.size.height + 2 * Self.slideMargin)

      let anim =
        isOpening
        ? CAAnimation.slideOut(with: direction, containerSize: containerSize, shouldFade: false)
        : CAAnimation.slideIn(with: direction, containerSize: containerSize, shouldFade: false)

      anim.timingFunction = CAMediaTimingFunction(
        name: isOpening ? CAMediaTimingFunctionName.easeIn : .easeOut)
      return anim
    }
  }

#endif
