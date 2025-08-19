import Foundation

extension Definition {

  public enum `PaymentMethod`: String, Encodable, Sendable {
    case `creditCard` = "credit_card"
    case `invoice`
  }
}
