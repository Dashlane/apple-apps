import Foundation

public protocol DeviceRegistrationValidator: AnyObject {
    var delegate: DeviceRegistrationValidatorDelegate? { get set }
}

public protocol DeviceRegistrationValidatorDelegate: AnyObject {
    func deviceRegistrationValidatorDidFetch(_ remoteAuthenticationData: DeviceRegistrationData)
}

public enum DeviceRegistrationValidatorEnumeration {
    case tokenByEmail(TokenDeviceRegistrationValidator)
    case thirdPartyOTP(ThirdPartyOTPDeviceRegistrationValidator)
    case loginViaSSO(SSODeviceRegistrationValidator)
    case authenticator(TokenDeviceRegistrationValidator)
    
    var validator: DeviceRegistrationValidator {
        switch self {
        case let .tokenByEmail(validator):
            return validator
        case let .thirdPartyOTP(validator):
            return validator
        case let .loginViaSSO(validator):
            return validator
        case let .authenticator(validator):
            return validator
        }
    }
}
