import BrazeKit
import Foundation
import UIKit

struct BrazeAnnouncementCTA {

  let identifier: Int
  let title: String
  let action: BrazeAnnouncementAction

  init(
    identifier: Int,
    title: String,
    action: BrazeAnnouncementAction
  ) {
    self.identifier = identifier
    self.title = title
    self.action = action
  }

  init(button: Braze.InAppMessage.Button) throws {
    self.identifier = button.id
    self.title = button.text
    guard button.clickAction != .none else {
      self.action = .close
      return
    }
    guard let url = button.clickAction.url else {
      throw BrazeAnnouncementDecodingError.missingURLActionInButton
    }

    guard url.isValidBrazeAction() else {
      throw BrazeAnnouncementDecodingError.urlActionNotRedirectingToDashlane
    }

    self.action = .openURL(url)
  }
}

extension BrazeAnnouncementCTA {
  func performAction() {
    switch action {
    case let .openURL(url):
      UIApplication.shared.open(url)
    case .close:
      break
    }
  }
}

enum BrazeAnnouncementAction: Equatable {
  case openURL(URL)
  case close
}
