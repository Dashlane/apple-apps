import Foundation

public protocol AccountInfoProtocol {
        var loginOTPOption: ThirdPartyOTPOption? { get }
        var deviceRegistrationMethod: LoginMethod? { get }
    var isAccountRegistered: Bool { get }
}
