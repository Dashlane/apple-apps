import Foundation

extension Definition {

public enum `ErrorCheckout`: String, Encodable {
case `authentication`
case `cardDeclined` = "card_declined"
case `expiredCard` = "expired_card"
case `unexpectedUnknown` = "unexpected_unknown"
}
}