import Foundation

extension Data {
  public init?(base64URLEncoded: String) {
    self.init(base64Encoded: base64URLEncoded.base64URLDecoded())
  }

  public func base64URLEncoded() -> String {
    self.base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
  }

  public func base64URLEncodedData() -> Data {
    self.base64EncodedString().data(using: .utf8)!
  }
}

extension String {
  public func base64URLDecoded() -> String {
    var result = self.replacingOccurrences(of: "-", with: "+").replacingOccurrences(
      of: "_", with: "/")
    let paddingLength = 4 - (result.count % 4)
    if paddingLength < 4 {
      result.append(String(repeating: "=", count: paddingLength))
    }

    return result
  }
}
