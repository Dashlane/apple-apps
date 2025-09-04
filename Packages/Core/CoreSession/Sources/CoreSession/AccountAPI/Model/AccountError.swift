import CoreTypes
import Foundation

public enum AccountError: String, Error {
  case invalidEmail
  case userNotFound = "user_not_found"
  case invalidInput
  case malformed
  case unknown
}
