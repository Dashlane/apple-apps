import Foundation
import DashTypes

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

public struct SSOInfo: Decodable, Equatable {
    let serviceProviderUrl: String
    let migration: SSOMigrationType?
    let isNitroProvider: Bool?
}

public struct LoginResponse: Decodable {
    let profilesToDelete: [Profile]
    public let verifications: [TwoFactorAuthenticationLogin]

    enum CodingKeys: String, CodingKey {
        case profilesToDelete
        case verifications
    }

    init(profilesToDelete: [Profile], verification: [TwoFactorAuthenticationLogin]) {
        self.profilesToDelete = profilesToDelete
        self.verifications = verification
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        profilesToDelete = try container.decodeIfPresent([Profile].self, forKey: .profilesToDelete) ?? []
        verifications = try container.decode(FailableDecodableArray<TwoFactorAuthenticationLogin>.self, forKey: .verifications).elements
    }

        func loginMethod(for login: Login, with context: LoginContext? = nil) -> LoginMethod? {
        let types = verifications.map { $0.type }
        if types.contains(.token) {
            return .tokenByEmail()
        } else if types.contains(.duoPush) {
            return .thirdPartyOTP(.duoPush)
        } else if types.contains(.totp) && types.contains(.authenticator) {
            return .thirdPartyOTP(.authenticatorPush)
        } else if types.contains(.totp) {
            return .thirdPartyOTP(.totp)
        } else if types.contains(.authenticator) {
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
    
    public var isOTP1Enabled: Bool {
        let types = verifications.map { $0.type }
        if types.contains(.duoPush) || types.contains(.totp) {
            return true
        } else  {
            return false
        }
    }
    
    public var ssoInfo: SSOInfo? {
        verifications.filter({ $0.type == .sso}).first?.ssoInfo
    }
}

extension LoginResponse {
    func loginOTPOption(for login: Login, with context: LoginContext?) -> ThirdPartyOTPOption? {
        switch loginMethod(for: login, with: context) {
        case .thirdPartyOTP(let option, _):
            return option
        default:
            return nil
        }
    }
    
    func isPartOfSSOCompany(for login: Login, with context: LoginContext?) -> Bool {
        switch loginMethod(for: login, with: context) {
        case .loginViaSSO:
            return true
        default:
            return false
        }
    }
    
}
