import Foundation
import TOTPGenerator
import CoreUserTracking
import DashlaneCrypto

public extension OTPInfo {
    
    var authenticatorIssuerId: String? {
        let issuer = configuration.issuer ?? configuration.title
        if let hash = SHA.hash(text: issuer, using: .sha256) {
            return hash.base64EncodedString()
        }
        return nil
    }
    
    var logSpecifications: Definition.OtpSpecifications {
        return Definition.OtpSpecifications(durationOtpValidity: configuration.type.period, encryptionAlgorithm: configuration.algorithm.logAlgorithm, otpCodeSize: configuration.digits, otpIncrementCount: configuration.type.counter, otpType: Definition.OtpType(rawValue: configuration.type.rawValue)!)
    }
}

private extension HashAlgorithm {
    var logAlgorithm: Definition.EncryptionAlgorithm {
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
