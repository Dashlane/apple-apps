import Foundation
import DashTypes

public protocol DeviceInformationProtocol: Encodable { }

public struct DeviceInfoService {

	public let webService: LegacyWebService

	public init(webService: LegacyWebService) {
		self.webService = webService
	}

		public func updateInformation<Information: DeviceInformationProtocol>(
        with information: Information,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {

		let endpoint = "/1/devices/updateDeviceInformation"

		guard let json = try? JSONEncoder().encode(information),
			let deviceInformation = String(data: json, encoding: .utf8) else {
			completion(.failure(DeviceServiceError.couldNotEncodeDeviceInformation))
			return
		}

		let parameters: [String: Encodable] = [
			"deviceInformation": deviceInformation
		]

		webService.sendRequest(to: endpoint,
							   using: .post,
							   params: parameters,
							   contentFormat: .queryString,
							   needsAuthentication: true,
							   responseParser: UpdateInformationResponseParser(),
							   completion: completion)
	}

	public enum DeviceServiceError: Error {
		case couldNotEncodeDeviceInformation
		case responseNotOk
		case decodingError
	}

	private struct UpdateInformationResponseParser: ResponseParserProtocol {

		private struct Response: Decodable {
			let code: Int
			let message: String
		}

		func parse(data: Data) throws {
			let response: Response
			do {
				response = try JSONDecoder().decode(Response.self, from: data)
			} catch {
				throw DeviceServiceError.decodingError
			}
			guard response.code == 200, response.message == "OK" else {
				throw DeviceServiceError.responseNotOk
			}
		}
	}
}
