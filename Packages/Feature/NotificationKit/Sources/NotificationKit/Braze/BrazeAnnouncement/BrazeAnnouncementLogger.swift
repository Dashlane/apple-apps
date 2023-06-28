import Foundation
import BrazeKit

protocol BrazeAnnouncementLogger {
    func display()
    func tapped(button: BrazeAnnouncementCTA)
    func discard()
}

extension Braze.InAppMessage: BrazeAnnouncementLogger {

            private var isAllowedToLogToBraze: Bool {
        return !ProcessInfo.isTesting
    }

    func display() {
        guard isAllowedToLogToBraze else { return }
        self.context?.logImpression()
    }

    func tapped(button: BrazeAnnouncementCTA) {
        guard isAllowedToLogToBraze else { return }
        self.context?.logClick(buttonId: String(button.identifier))
    }

    func discard() {
        guard isAllowedToLogToBraze else { return }
        self.context?.logError(flattened: "Excluded")
    }
}

struct BrazeAnnouncementLoggerMock: BrazeAnnouncementLogger {
    func display() {

    }

    func tapped(button: BrazeAnnouncementCTA) {

    }

    func discard() {

    }
}
