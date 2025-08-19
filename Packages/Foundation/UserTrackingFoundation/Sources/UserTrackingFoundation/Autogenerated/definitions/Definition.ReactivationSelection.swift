import Foundation

extension Definition {

  public enum `ReactivationSelection`: String, Encodable, Sendable {
    case `createAccount` = "create_account"
    case `login`
    case `neverAsk` = "never_ask"
  }
}
