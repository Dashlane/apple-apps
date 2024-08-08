import Foundation

struct FileBreachesResponse: Decodable {

  let revision: Int

  var breaches: Set<PublicBreach> = []

  enum CodingKeys: CodingKey {
    case revision
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.revision = try container.decode(Int.self, forKey: .revision)
  }
}
