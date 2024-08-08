import Foundation

extension Definition {

  public enum `ErrorCheckout`: String, Encodable, Sendable {
    case `authentication`
    case `cardDeclined` = "card_declined"
    case `expiredCard` = "expired_card"
    case `unexpectedUnknown` = "unexpected_unknown"
  }
}
