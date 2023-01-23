import Foundation
import SwiftUI
import UIKit

class GuidedOnboardingTransitionHandler {
    var lastState: TransitionState?
    weak var navigationController: DashlaneNavigationController?
    let interactionController: UIPercentDrivenInteractiveTransition?
    let completion: (() -> Void)?

    enum TransitionState {
        case changed(DragGesture.Value)
        case end
    }

    init(navigationController: DashlaneNavigationController,
         interactionController: UIPercentDrivenInteractiveTransition?,
         completion: (() -> Void)? = nil) {
        self.completion = completion
        self.navigationController = navigationController
        self.interactionController = interactionController
    }

    func update(state: TransitionState) {
        guard let navigationController = navigationController else {
            return
        }
        switch state {
        case .changed(let value):
            if self.lastState == nil {
                navigationController.dismiss(animated: true, completion: completion)
            }
            interactionController?.update(percentCompleted(fromValue: value, relativeToView: navigationController.view))
        case .end:
            interactionController?.finish()
        }
        lastState = state
    }

    func dismiss() {
        navigationController?.dismiss(animated: true, completion: completion)
        interactionController?.finish()
    }

    private func percentCompleted(fromValue value: DragGesture.Value, relativeToView view: UIView) -> CGFloat {
        max(0, 1.0 - (-value.translation.height / view.convert(.zero, to: nil).y))
    }
}
