import Foundation

extension Definition {

  public struct `Android`: Encodable, Sendable {
    public init(`adid`: String? = nil, `advertisingId`: String? = nil, `androidId`: String) {
      self.adid = adid
      self.advertisingId = advertisingId
      self.androidId = androidId
    }
    public let adid: String?
    public let advertisingId: String?
    public let androidId: String
  }
}
