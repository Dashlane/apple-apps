import Foundation

extension Definition {

  public enum `FormType`: String, Encodable, Sendable {
    case `billing`
    case `changePassword` = "change_password"
    case `contact`
    case `forgotPassword` = "forgot_password"
    case `identity`
    case `login`
    case `newsletter`
    case `other`
    case `payment`
    case `register`
    case `search`
    case `shipping`
    case `shoppingBasket` = "shopping_basket"
  }
}
