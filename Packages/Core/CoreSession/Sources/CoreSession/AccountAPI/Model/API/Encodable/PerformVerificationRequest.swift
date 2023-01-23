import Foundation

public protocol PerformVerificationRequest: Encodable {
    var login: String { get }
    static var endPoint: String { get }
}

public struct PerformTokenVerificationRequest: PerformVerificationRequest {
    public let login: String
    public let token: String

    public static var endPoint: String {
        return "v1/authentication/PerformEmailTokenVerification"
    }
}

public struct PerformTOTPVerificationRequest: PerformVerificationRequest {
    public let login: String
    public let otp: String
    public let activationFlow: Bool
    
    public static var endPoint: String {
        return "v1/authentication/PerformTotpVerification"
    }
    
    public init(login: String, otp: String, activationFlow: Bool = false) {
        self.login = login
        self.otp = otp
        self.activationFlow = activationFlow
    }
}

public struct PerformDuoPushVerificationRequest: PerformVerificationRequest {
    public let login: String
    public static var endPoint: String {
        return "v1/authentication/PerformDuoPushVerification"
    }
}

public struct PerformSSOVerificationRequest: PerformVerificationRequest {
    public let login: String
    public let ssoToken: String

    public static var endPoint: String {
        return "v1/authentication/PerformSsoVerification"
    }
}

public struct PerformAuthenticatorPushVerificationRequest: PerformVerificationRequest {
    public let login: String
    public static var endPoint: String {
        return "v1/authentication/PerformDashlaneAuthenticatorVerification"
    }
}
