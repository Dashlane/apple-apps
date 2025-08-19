import Foundation

extension AnonymousEvent {

  public struct `AuthenticatorRemoveOtpCode`: Encodable, AnonymousEventProtocol {
    public static let isPriority = false
    public init(`authenticatorIssuerId`: String? = nil) {
      self.authenticatorIssuerId = authenticatorIssuerId
    }
    public let authenticatorIssuerId: String?
    public let name = "authenticator_remove_otp_code"
  }
}
