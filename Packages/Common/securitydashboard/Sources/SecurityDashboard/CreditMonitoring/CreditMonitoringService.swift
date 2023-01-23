import Foundation
import DashTypes

public struct CreditMonitoringService {

    let webService: LegacyWebService

    public init(webservice: LegacyWebService) {
        self.webService = webservice
    }

		public func getInformation() async throws -> CreditMonitoringGetInformationResponse {
		let resource = CreditMonitoringServiceResource.resource
        return try await resource.load(on: self.webService)
	}
}

struct CreditMonitoringResponseParser: ResponseParserProtocol {
    func parse(data: Data) throws -> CreditMonitoringGetInformationResponse {
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(DashlaneResponse<CreditMonitoringGetInformationResponse>.self, from: data)
            return response.content
        } catch {
            guard let errorResponse = try? decoder.decode(DashlaneResponse<CreditMonitoringServiceError>.self, from: data) else {
                throw error
            }
            throw errorResponse.content
        }
    }
}

private struct CreditMonitoringServiceResource {

	private static let endpoint = "/1/creditmonitoring/getConnectionInfo"

    static var resource: Resource<CreditMonitoringResponseParser> {
        return Resource(endpoint: endpoint,
                        method: .post,
                        params: [:],
                        contentFormat: .queryString,
                        needsAuthentication: true,
                        parser: CreditMonitoringResponseParser())
    }
}
