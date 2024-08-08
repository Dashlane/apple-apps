import Foundation

extension RSA {
  public enum RSAError: Error {
    case signFailed
    case encryptFailed
    case decryptFailed
  }
}
