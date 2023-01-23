import Foundation
import DashTypes

struct BreachesInfoService {

    private static let endpoint = "/1/breaches/get"

    static func resource(forRevision revision: Int = 0) -> Resource<BreachesInfoServiceParser> {
        return Resource(endpoint: endpoint,
                        method: .post,
                        params: ["revision": revision],
                        contentFormat: .queryString,
                        needsAuthentication: true,
                        parser: BreachesInfoServiceParser())
    }

}

struct BreachesInfoServiceParser: ResponseParserProtocol {
        func parse(data: Data) throws -> BreachQueryInfo {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let response = try decoder.decode(DashlaneResponse<BreachQueryInfo>.self, from: data)

        var breachQueryInfo = response.content
        breachQueryInfo.latest = data.breaches

        return breachQueryInfo
    }
}

private extension Data {

	var breaches: Set<Breach> {
		let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .secondsSince1970
		var breaches = Set<Breach>()
		if let json = (try? JSONSerialization.jsonObject(with: self, options: [])) as? [String: Any],
			let responseContent = json["content"] as? [String: Any],
			let breachesArray = responseContent["latest"] as? [[String: Any]] {
			for breachDictionary in breachesArray {

				guard let originalJsonData = try? JSONSerialization.data(withJSONObject: breachDictionary),
					let originalJsonString = String(data: originalJsonData, encoding: .utf8),
					var newbreach = try? jsonDecoder.decode(Breach.self, from: originalJsonData) else {
						continue
				}
				newbreach.originalContent = originalJsonString
				breaches.insert(newbreach)
			}
		}
		return breaches
	}
}
