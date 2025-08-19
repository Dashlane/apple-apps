import DashlaneAPI
import Foundation

public enum ThirdPartyOTPOption: String, Codable, Hashable, Sendable {
  case totp
  case duoPush
}

extension ThirdPartyOTPOption {
  public var pushType: VerificationMethod.PushType? {
    switch self {
    case .totp:
      return nil
    case .duoPush:
      return .duo
    }
  }
}

public enum LoginMethod: Hashable, Sendable {
  case tokenByEmail(_ u2fChallenges: [U2FChallenge] = [])
  case thirdPartyOTP(ThirdPartyOTPOption, u2fChallenges: [U2FChallenge] = [])
  case loginViaSSO(SSOAuthenticationInfo)
}

public typealias SSOMigrationType = AuthenticationMigration
