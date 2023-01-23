import Foundation
#if !os(macOS)
import UIKit

public class FadeInAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration: TimeInterval

    public init(duration: TimeInterval = 0.3) {
        self.duration = duration
        super.init()
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toViewController = transitionContext.viewController(forKey: .to)
            else {
                return
        }
        toViewController.view.translatesAutoresizingMaskIntoConstraints = false
        transitionContext.containerView.addSubview(toViewController.view)
        toViewController.view.alpha = 0

        NSLayoutConstraint.activate([
            toViewController.view.leadingAnchor.constraint(equalTo: transitionContext.containerView.leadingAnchor),
            toViewController.view.trailingAnchor.constraint(equalTo: transitionContext.containerView.trailingAnchor),
            toViewController.view.topAnchor.constraint(equalTo: transitionContext.containerView.topAnchor),
            toViewController.view.bottomAnchor.constraint(equalTo: transitionContext.containerView.bottomAnchor)
        ])
        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            toViewController.view.alpha = 1
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

public class FadeOutAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration: TimeInterval

    public init(duration: TimeInterval = 0.3) {
        self.duration = duration
        super.init()
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from)
            else {
                return
        }

        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            fromViewController.view.alpha = 0
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

#endif
