import Foundation

public enum AuthenticationMode: Hashable, Sendable {
  case masterPassword

  case resetMasterPassword

  case biometry

  case pincode

  case rememberMasterPassword

  case accountRecovered(_ newMasterPassword: String)

  case sso
}

public enum LocalLoginVerificationMode: String, Encodable, Sendable {
  case none
  case otp2
}
