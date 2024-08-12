import Foundation

public struct AttestedCredentialData: Equatable {
  public let aaguid: [UInt8]
  public let credentialID: [UInt8]
  public let publicKey: [UInt8]
}

extension AttestedCredentialData {
  func bytesRepresentation() -> [UInt8] {
    var result = [UInt8]()
    result += aaguid
    result += credentialID.count.uint8Array().suffix(2)
    result += credentialID
    result += publicKey
    return result
  }
}

extension Int {
  fileprivate func uint8Array() -> [UInt8] {
    return withUnsafeBytes(of: self.bigEndian) {
      Array($0)
    }
  }
}
