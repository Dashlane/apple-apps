import CryptoKit
import Foundation

extension String {
  public func sha512() -> String? {
    guard let stringData = data(using: .utf8, allowLossyConversion: true) else {
      return nil
    }
    let digest = SHA512.hash(data: stringData)
    return digest.map { String(format: "%02hhx", $0) }.joined()
  }

  public func md5() -> String? {
    guard let stringData = data(using: .utf8, allowLossyConversion: true) else {
      return nil
    }
    let digest = Insecure.MD5.hash(data: stringData)
    return digest.map { String(format: "%02hhx", $0) }.joined()
  }
}
