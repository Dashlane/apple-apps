import Foundation
import UIKit

class ActionableTextField: UITextField {
        var allowedActions: [StandardActions] = StandardActions.allCases


        enum StandardActions: CaseIterable {
        case copy
        case cut
        case paste

        var correspondingSelector: Selector {
            switch self {
            case .copy:
                return #selector(UIResponderStandardEditActions.copy(_:))
            case .cut:
                return #selector(UIResponderStandardEditActions.cut(_:))
            case .paste:
                return #selector(UIResponderStandardEditActions.paste(_:))
            }
        }

        func matches(_ selector: Selector) -> Bool {
            return selector == correspondingSelector
        }
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        let isAllowed = allowedActions.contains { $0.matches(action) }
        return isAllowed || super.canPerformAction(action, withSender: sender)
    }
}
