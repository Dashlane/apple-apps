import CryptoKit
import DashTypes
import Foundation

extension Login {
  private static let usernameHashMaxLength = 32

  func appAccountToken() throws -> UUID {
    guard let data = email.data(using: .utf8) else {
      throw PurchaseError.couldNotHashLogin
    }

    let hashed = SHA512.hash(data: data)
    let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()

    let uuidString = String(hashString.prefix(32))

    var formattedUUID = ""
    let indices = Set([8, 12, 16, 20])
    for (index, char) in uuidString.enumerated() {
      if indices.contains(index) {
        formattedUUID.append("-")
      }
      formattedUUID.append(char)
    }

    guard let uuid = UUID(uuidString: formattedUUID) else {
      throw PurchaseError.couldNotHashLogin
    }

    return uuid
  }
}
