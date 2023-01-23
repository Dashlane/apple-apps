import UIKit

class FiberUIApplication: UIApplication {
    static let didReceiveTouchNotification = NSNotification.Name(rawValue: "didReceiveTouchNotification")

        override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)

        if event.type == .touches,
            let touches = event.allTouches,
            touches.contains(where: { $0.phase == .began || $0.phase == .ended }) {
            NotificationCenter.default.post(name: Self.didReceiveTouchNotification, object: self)
        }
    }
}
