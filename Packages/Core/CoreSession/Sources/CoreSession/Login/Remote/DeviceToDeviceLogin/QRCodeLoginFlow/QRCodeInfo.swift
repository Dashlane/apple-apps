import DashTypes
import Foundation

public struct QRCodeInfo: Hashable, Sendable {

  public enum CodingKey: String {
    case id
    case key
  }

  public let id: String
  public let publicKey: Base64EncodedString

  public init?(qrCode: String) {
    let cleaned =
      qrCode.removingPercentEncoding?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
      ?? qrCode
    guard let url = URL(string: cleaned) else {
      return nil
    }
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
      return nil
    }
    self.init(urlComponents: components)
  }

  public init?(urlComponents: URLComponents) {
    guard urlComponents.path.contains("mplesslogin"),
      let id = urlComponents.queryItems?[CodingKey.id.rawValue],
      let key = urlComponents.queryItems?[CodingKey.key.rawValue]
    else {
      return nil
    }
    self.init(publicKey: key, id: id)
  }

  public init(publicKey: String, id: String) {
    self.publicKey = publicKey
    self.id = id
  }

}
