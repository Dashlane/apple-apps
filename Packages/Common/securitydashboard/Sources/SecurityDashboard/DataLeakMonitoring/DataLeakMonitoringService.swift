import Foundation
import DashTypes

public struct DataLeakMonitoringService {

    let webService: LegacyWebService

    public init(webservice: LegacyWebService) {
        self.webService = webservice
    }
}

private struct DataLeakMonitoringServiceResource {

    static func opt(forRequest request: DataLeakMonitoringRequest) -> Resource<DataLeakMonitoringResponseParser<DataLeakMonitoringOptResponse>> {
        return Resource(endpoint: request.endpoint,
                        method: .post,
                        params: request.dictionaryParameter,
                        contentFormat: .queryString,
                        needsAuthentication: true,
                        parser: DataLeakMonitoringResponseParser<DataLeakMonitoringOptResponse>())
    }

    static func status() -> Resource<DataLeakMonitoringResponseParser<DataLeakMonitoringStatusResponse>> {
        let request = DataLeakMonitoringRequest.status
        return Resource(endpoint: request.endpoint,
                        method: .post,
                        params: request.dictionaryParameter,
                        contentFormat: .queryString,
                        needsAuthentication: true,
                        parser: DataLeakMonitoringResponseParser<DataLeakMonitoringStatusResponse>())
    }

    static func leaks(timeInterval: TimeInterval?, plaintextData: Bool) -> Resource<DataLeakMonitoringResponseParser<DataLeakMonitoringLeaksResponse>> {
        let request = plaintextData ? DataLeakMonitoringRequest.leaksWithPlaintextData(timeInterval) : DataLeakMonitoringRequest.leaks(timeInterval)
        return Resource(endpoint: request.endpoint,
                        method: .post,
                        params: request.dictionaryParameter,
                        contentFormat: .queryString,
                        needsAuthentication: true,
                        parser: DataLeakMonitoringResponseParser<DataLeakMonitoringLeaksResponse>())
    }
}

public extension DataLeakMonitoringService {

    func register(emails: [String]) async throws -> DataLeakMonitoringOptResponse {
		let request = DataLeakMonitoringRequest.optin(emails)
        return try await DataLeakMonitoringServiceResource.opt(forRequest: request).load(on: webService)
	}

    func unregister(emails: [String]) async throws -> DataLeakMonitoringOptResponse {
		let request = DataLeakMonitoringRequest.optout(emails)
		return try await DataLeakMonitoringServiceResource.opt(forRequest: request).load(on: webService)
	}

	func status() async throws -> DataLeakMonitoringStatusResponse {
        try await DataLeakMonitoringServiceResource.status().load(on: webService)
	}

    func leaks(lastUpdateDate: TimeInterval?) async throws -> DataLeakMonitoringLeaksResponse {
        let request = DataLeakMonitoringServiceResource.leaks(timeInterval: lastUpdateDate, plaintextData: false)
        return try await request.load(on: webService)
    }

    func leaksWithPlaintextData(lastUpdateDate: TimeInterval?) async throws -> DataLeakMonitoringLeaksResponse {
        let request = DataLeakMonitoringServiceResource.leaks(timeInterval: lastUpdateDate, plaintextData: true)
        return try await request.load(on: webService)
    }
}
