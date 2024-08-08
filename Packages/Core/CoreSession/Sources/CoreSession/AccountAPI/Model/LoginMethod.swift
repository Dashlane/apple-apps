import DashlaneAPI
import Foundation

public enum ThirdPartyOTPOption: String, Codable, Hashable, Sendable {
  case totp
  case duoPush
  case authenticatorPush
}

extension ThirdPartyOTPOption {
  public var pushType: VerificationMethod.PushType? {
    switch self {
    case .totp:
      return nil
    case .duoPush:
      return .duo
    case .authenticatorPush:
      return .authenticator
    }
  }
}

public enum LoginMethod: Hashable {
  case tokenByEmail(_ u2fChallenges: [U2FChallenge] = [])
  case thirdPartyOTP(ThirdPartyOTPOption, u2fChallenges: [U2FChallenge] = [])
  case loginViaSSO(SSOAuthenticationInfo)
  case authenticator
}

public typealias SSOMigrationType = AuthenticationMigration
