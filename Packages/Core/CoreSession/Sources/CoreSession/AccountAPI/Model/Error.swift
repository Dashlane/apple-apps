import CoreTypes
import Foundation

public enum RequestError: String, Error, Decodable {
  case incorrectAuthentication = "Incorrect authentification"
  case badOTP = "Bad OTP"
  case badSSO = "Bad SSO"
  case locked = "Lock already acquired"
  case unknown = "An error happened"
}

public enum TokenError: String, Error, Decodable {
  case otpActivated = "OTP_NEEDED"
  case throttled = "Throttled."
  case notOk = "NOK"
  case unknown
}

public enum AccountExistsError: Error {
  case invalidValue
  case unlikelyValue
  case unknownError
}

public enum OTPError: String {
  case unregistered
  case unknown
}

public enum AccountCreationError: String, Error {
  case invalidEmail = "invalid_contact_email"
  case expiredVersion = "expired_version"
  case unknown
}
