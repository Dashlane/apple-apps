import Foundation

extension Definition {

  public struct `WebAccountCreation`: Encodable, Sendable {
    public init(
      `everflowTransactionId`: String? = nil, `gclid`: String? = nil, `hasCookie`: Bool? = nil,
      `heapIdentity`: String? = nil
    ) {
      self.everflowTransactionId = everflowTransactionId
      self.gclid = gclid
      self.hasCookie = hasCookie
      self.heapIdentity = heapIdentity
    }
    public let everflowTransactionId: String?
    public let gclid: String?
    public let hasCookie: Bool?
    public let heapIdentity: String?
  }
}
