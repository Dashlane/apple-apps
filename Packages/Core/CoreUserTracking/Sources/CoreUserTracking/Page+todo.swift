import Foundation
import UserTrackingFoundation

extension Page {

  @available(*, deprecated, message: "please replace with the correct log")
  static func todo(_ comment: String? = "") -> Page {
    return Page.accountCreation
  }
}
