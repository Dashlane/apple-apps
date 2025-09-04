import CryptoKit
import Foundation
import TOTPGenerator
import UserTrackingFoundation

extension OTPInfo {

  public var authenticatorIssuerId: String? {
    let issuer = configuration.issuer ?? configuration.title
    if let data = issuer.data(using: .utf8) {
      return Data(SHA256.hash(data: data)).base64EncodedString()
    }
    return nil
  }

  public var logSpecifications: Definition.OtpSpecifications {
    return Definition.OtpSpecifications(
      durationOtpValidity: configuration.type.period,
      encryptionAlgorithm: configuration.algorithm.logAlgorithm,
      otpCodeSize: configuration.digits,
      otpIncrementCount: configuration.type.counter,
      otpType: Definition.OtpType(rawValue: configuration.type.rawValue)!
    )
  }
}

extension HashAlgorithm {
  fileprivate var logAlgorithm: Definition.EncryptionAlgorithm {
    switch self {
    case .sha1:
      return .sha1
    case .sha256:
      return .sha256
    case .sha512:
      return .sha512
    }
  }
}
