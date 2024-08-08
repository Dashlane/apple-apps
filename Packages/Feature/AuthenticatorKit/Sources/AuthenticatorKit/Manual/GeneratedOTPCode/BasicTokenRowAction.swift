import Foundation

public enum BasicTokenRowAction {
  case copy(_ code: String, token: OTPInfo)
  case delete(OTPInfo)
}
