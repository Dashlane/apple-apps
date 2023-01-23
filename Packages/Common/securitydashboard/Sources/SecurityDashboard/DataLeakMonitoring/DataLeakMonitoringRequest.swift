import Foundation
import DashTypes

protocol DataLeakMonitoringResponseProtocol: Codable {
    init(object: Self, originalData: Data)
}

public enum DataLeakMonitoringRequest {
	case optin([String])
	case optout([String])
	case scan(String)
	case status
	case leaks(TimeInterval?)
    case leaksWithPlaintextData(TimeInterval?)

        var endpoint: String {
        let finalEndpoint = "/1/dataleak"
        switch self {
        case .optin: return finalEndpoint + "/optin"
        case .optout: return finalEndpoint + "/optout"
        case .scan: return finalEndpoint + "/scan"
        case .status: return finalEndpoint + "/status"
        case .leaks, .leaksWithPlaintextData: return finalEndpoint + "/leaks"
        }
    }

        var parameters: [String: Encodable?] {
        switch self {
        case .optin(let emails), .optout(let emails):
            guard let emailsJSON = try? JSONSerialization.data(withJSONObject: emails, options: []),
                let emailsString = String.init(data: emailsJSON, encoding: .utf8) else {
                    return [:]
            }
            return ["emails": emailsString]
        case .scan(let email):
            return ["email": email]
        case .status:
            return ["wantsLeaks": "false"]
        case .leaks(let lastUpdateDate):
                        return [
                "includeDisabled": "true",
                "lastUpdateDate": lastUpdateDate
            ]
        case .leaksWithPlaintextData(let lastUpdateDate):
            return [
                "lastUpdateDate": lastUpdateDate,
				"includeDisabled": "true",
                "wantsDetails": "true"
            ]
        }
	}

    var dictionaryParameter: [String: Encodable] {
        return parameters.reduce(into: [String: Encodable]()) { (result, data) in
            guard let value = data.value else { return }
            result[data.key] = value
        }
    }
}

struct DataLeakMonitoringResponseParser<T: DataLeakMonitoringResponseProtocol>: ResponseParserProtocol {

    func parse(data: Data) throws -> T {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            let response = try decoder.decode(DashlaneResponse<T>.self, from: data)
			return T(object: response.content, originalData: data)
		} catch {
            if let httpResponse = try? JSONDecoder().decode(HTTPResponse.self, from: data),
                httpResponse.code == 304 {
                throw DataLeakMonitoringServiceError.contentDidNotChange
            }
			throw DataLeakMonitoringServiceError.unknownError(error)
		}
	}
}

private struct HTTPResponse: Decodable {
    let code: Int
}
