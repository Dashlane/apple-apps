import Foundation

extension Definition {

  public struct `Ios`: Encodable, Sendable {
    public init(
      `adid`: String? = nil, `advertisingId`: String? = nil, `idfa`: String? = nil,
      `idfv`: String? = nil
    ) {
      self.adid = adid
      self.advertisingId = advertisingId
      self.idfa = idfa
      self.idfv = idfv
    }
    public let adid: String?
    public let advertisingId: String?
    public let idfa: String?
    public let idfv: String?
  }
}
