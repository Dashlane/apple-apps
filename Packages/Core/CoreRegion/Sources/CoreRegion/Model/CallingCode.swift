import Foundation

public struct CallingCode: Decodable {
  public let region: String
  public let dialingCode: Int
}
