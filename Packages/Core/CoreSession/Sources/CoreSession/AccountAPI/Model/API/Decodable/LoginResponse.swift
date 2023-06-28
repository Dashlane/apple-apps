import Foundation
import DashTypes
import DashlaneAPI

public struct LoginContext {
    public enum Origin: String {
        case safari
        case mobile
    }

    public let origin: Origin

    public init(origin: Origin) {
        self.origin = origin
    }
}

public typealias LoginResponse = AppAPIClient.Authentication.GetAuthenticationMethodsForLogin.Response
public typealias SSOInfo = AuthenticationSsoInfo

public extension Array where Element == AuthenticationGetMethodsVerifications {
    func loginMethod(for login: Login, with context: LoginContext? = nil) -> LoginMethod? {
        let types = self.map { $0.type }
        if types.contains(.emailToken) {
            return .tokenByEmail()
        } else if types.contains(.duoPush) {
            return .thirdPartyOTP(.duoPush)
        } else if types.contains(.totp) && types.contains(.dashlaneAuthenticator) {
            return .thirdPartyOTP(.authenticatorPush)
        } else if types.contains(.totp) {
            return .thirdPartyOTP(.totp)
        } else if types.contains(.dashlaneAuthenticator) {
            return .authenticator
        } else if types.contains(.sso) {
            guard let string = ssoInfo?.serviceProviderUrl,
                  let context = context,
                  let url = URL(string: "\(string)?redirect=\(context.origin.rawValue)&username=\(login.email)&frag=true"),
                  url.scheme != nil else {
                return nil
            }
            return .loginViaSSO(serviceProviderUrl: url, isNitroProvider: ssoInfo?.isNitroProvider ?? false)
        }
        return nil
    }

    var isOTP1Enabled: Bool {
        let types = self.map { $0.type }
        if types.contains(.duoPush) || types.contains(.totp) {
            return true
        } else {
            return false
        }
    }

    var ssoInfo: AuthenticationSsoInfo? {
        self.filter({ $0.type == .sso}).first?.ssoInfo
    }
}

public extension LoginMethod {
    var otpOption: ThirdPartyOTPOption? {
        switch self {
        case .thirdPartyOTP(let option, _):
            return option
        default:
            return nil
        }
    }
}

public extension LoginResponse {
    var userAccountType: AccountType {
        guard verifications.ssoInfo == nil else {
            return .sso
        }
        switch accountType {
        case .masterPassword:
            return .masterPassword
        case .invisibleMasterPassword:
            return .invisibleMasterPassword
        }
    }
}
