import Foundation

struct BreachesQueryInfo: Decodable {

		let revision: Int

		var breaches: Set<Breach> = []

	enum CodingKeys: CodingKey {
		case revision
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		self.revision = try container.decode(Int.self, forKey: .revision)
	}
}
