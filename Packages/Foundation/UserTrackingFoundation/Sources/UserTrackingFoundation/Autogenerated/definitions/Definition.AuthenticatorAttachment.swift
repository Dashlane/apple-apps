import Foundation

extension Definition {

  public enum `AuthenticatorAttachment`: String, Encodable, Sendable {
    case `crossPlatform` = "cross_platform"
    case `platform`
  }
}
