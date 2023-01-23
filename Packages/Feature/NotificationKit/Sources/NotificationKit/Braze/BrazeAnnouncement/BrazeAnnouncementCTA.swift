import Foundation
import BrazeKit
import UIKit

struct BrazeAnnouncementCTA {

    let identifier: Int
    let title: String
    let action: BrazeAnnouncementAction

    init(identifier: Int,
                  title: String,
                  action: BrazeAnnouncementAction) {
        self.identifier = identifier
        self.title = title
        self.action = action
    }

    init(button: Braze.InAppMessage.Button) throws {
        self.identifier = button.id
        self.title = button.text
        guard let url = button.clickAction.url else {
            throw BrazeAnnouncementDecodingError.missingURLActionInButton
        }

        guard url.isValidBrazeAction() else {
            throw BrazeAnnouncementDecodingError.urlActionNotReditectingToDashlane
        }

        self.action = .openURL(url)
    }
}

extension BrazeAnnouncementCTA {
    func performAction() {
        switch action {
        case let .openURL(url):
            UIApplication.shared.open(url)
        }
    }
}

enum BrazeAnnouncementAction: Equatable {
    case openURL(URL)
}
