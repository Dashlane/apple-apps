import Foundation
extension UserDeviceAPIClient.Icons {
        public struct RequestIcons {
        public static let endpoint: Endpoint = "/icons/RequestIcons"

        public let api: UserDeviceAPIClient

                @discardableResult
        public func callAsFunction(domains: [String], timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(domains: domains)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var requestIcons: RequestIcons {
        RequestIcons(api: api)
    }
}

extension UserDeviceAPIClient.Icons.RequestIcons {
        struct Body: Encodable {

                public let domains: [String]
    }
}

extension UserDeviceAPIClient.Icons.RequestIcons {
    public typealias Response = Empty?
}
