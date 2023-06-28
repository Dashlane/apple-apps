import Foundation

public protocol DeviceRegistrationValidator: AnyObject {
    var deviceRegistrationValidatorDidFetch: ((DeviceRegistrationData) -> Void)? { get set }
}

public enum DeviceRegistrationValidatorEnumeration {
    case tokenByEmail
    case thirdPartyOTP(ThirdPartyOTPOption)
    case loginViaSSO(SSODeviceRegistrationValidator)
    case authenticator

    var validator: DeviceRegistrationValidator? {
        switch self {
        case let .loginViaSSO(validator):
            return validator
        default:
            return nil
        }
    }
}
