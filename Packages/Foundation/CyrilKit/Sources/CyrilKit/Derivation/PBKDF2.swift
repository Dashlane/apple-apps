import CommonCrypto
import Foundation

public struct PBKDF2: DerivationFunction {
  public enum Algorithm {
    case sha1
    case sha224
    case sha256
    case sha384
    case sha512
  }

  public let algorithm: Algorithm
  public let derivedKeyLength: Int
  public let numberOfIterations: UInt32

  public init(
    algorithm: Algorithm = .sha512,
    derivedKeyLength: Int = 32,
    numberOfIterations: UInt32 = 200000
  ) {
    self.algorithm = algorithm
    self.derivedKeyLength = derivedKeyLength
    self.numberOfIterations = numberOfIterations
  }

  public func derivateKey<V: ContiguousBytes, S: ContiguousBytes>(from password: V, salt: S) throws
    -> Data
  {
    var derivedKey = [UInt8](repeating: 0, count: derivedKeyLength)
    derivedKey.withUnsafeMutableBytes { bytes -> Void in
      password.withUnsafeBytes { passwordBytes -> Void in
        salt.withUnsafeBytes { saltBytes -> Void in
          CCKeyDerivationPBKDF(
            CCPBKDFAlgorithm(kCCPBKDF2),
            passwordBytes.bindMemory(to: CChar.self).baseAddress,
            passwordBytes.count,
            saltBytes.bindMemory(to: UInt8.self).baseAddress,
            saltBytes.count,
            algorithm.CCValue,
            numberOfIterations,
            bytes.bindMemory(to: UInt8.self).baseAddress,
            derivedKeyLength)
        }
      }
    }

    return Data(bytes: derivedKey, count: derivedKeyLength)
  }
}

extension PBKDF2.Algorithm {
  fileprivate var CCValue: CCPseudoRandomAlgorithm {
    switch self {
    case .sha1:
      return CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1)
    case .sha224:
      return CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA224)
    case .sha256:
      return CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256)
    case .sha384:
      return CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA384)
    case .sha512:
      return CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA512)
    }
  }
}
