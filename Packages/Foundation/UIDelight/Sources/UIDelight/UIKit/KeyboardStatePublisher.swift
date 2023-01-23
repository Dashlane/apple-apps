import Foundation
import Combine
#if !os(macOS)
import UIKit

extension UIResponder {
    public static func keyboardStatePublisher() -> AnyPublisher<Bool, Never> {
        let center = NotificationCenter.default
        let enabledPublisher = center.publisher(for: UIResponder.keyboardWillShowNotification).map { _ in true }
        let disabledPublisher = center.publisher(for: UIResponder.keyboardWillHideNotification).map { _ in false }

        return enabledPublisher.merge(with: disabledPublisher).eraseToAnyPublisher()
    }
}

#endif
