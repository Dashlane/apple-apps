import Foundation

public struct U2FChallenge: Codable, Equatable, Hashable {

  enum CodingKeys: String, CodingKey {
    case value = "challenge"
    case version
    case appId
    case keyHandle
  }

  let value: String
  let version: String
  let appId: String
  let keyHandle: String
}
