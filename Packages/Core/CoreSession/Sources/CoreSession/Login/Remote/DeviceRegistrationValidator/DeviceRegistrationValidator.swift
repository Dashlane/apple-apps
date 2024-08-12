import Foundation

public protocol DeviceRegistrationValidator: AnyObject {
  var deviceRegistrationValidatorDidFetch: ((DeviceRegistrationData) -> Void)? { get set }
}

public enum DeviceRegistrationValidatorEnumeration {
  case tokenByEmail
  case thirdPartyOTP(ThirdPartyOTPOption)
  case loginViaSSO(SSOAuthenticationInfo)
  case authenticator
}
