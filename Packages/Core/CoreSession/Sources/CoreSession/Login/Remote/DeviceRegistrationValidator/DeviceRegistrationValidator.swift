import Foundation

public enum DeviceRegistrationValidatorEnumeration: Hashable {
  case tokenByEmail
  case thirdPartyOTP(ThirdPartyOTPOption)
}
