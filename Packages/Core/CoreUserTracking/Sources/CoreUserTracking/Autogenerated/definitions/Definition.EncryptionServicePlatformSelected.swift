import Foundation

extension Definition {

  public enum `EncryptionServicePlatformSelected`: String, Encodable, Sendable {
    case `amazonWebServices` = "amazon_web_services"
    case `azure`
  }
}
