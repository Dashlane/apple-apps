import Foundation

struct BreachQueryInfo: Codable {

		let revision: Int

		let filesToDownload: [String]

		var latest: Set<Breach> = []
}
