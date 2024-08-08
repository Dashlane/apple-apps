import Foundation

struct Token: Decodable {

  enum CodingKeys: String, CodingKey {
    case value = "token"
    case login
  }

  let login: String
  let value: String
}
