import Foundation

public enum CryptoEngineError: Error, LocalizedError {
  public enum KeyMode {
    case direct
    case derived
  }
  case unsupportedConfiguration(configuration: CryptoConfiguration, key: KeyMode)
  case passwordEncodingFailure(encoding: String.Encoding)
  case invalidKeySize(size: Int, expected: Set<Int>)
  case insufficientData
  case invalidHMAC
  case configCannotCreateDerivationSalt
  case unsupportedCryptoVersion(Int)

  public var errorDescription: String? {
    switch self {
    case .unsupportedConfiguration(let configuration, let key):
      return "Unsupported configuration: \(configuration) for key mode: \(key)"
    case .passwordEncodingFailure(let encoding):
      return "Password to data conversion failed for encoding: \(encoding)"
    case .invalidKeySize(let size, let expected):
      return "Provided key size (\(size)) doesn't match expected size(s): \(expected)"
    case .insufficientData:
      return "Data provided is too small"
    case .invalidHMAC:
      return "The key or password is incorrect, or the data may be corrupted (Invalid HMAC)"
    case .configCannotCreateDerivationSalt:
      return "Cannot create a salt with the configuration since there is no key derivation"
    case let .unsupportedCryptoVersion(version):
      return "The crypto version \(version) is not supported"
    }
  }
}
