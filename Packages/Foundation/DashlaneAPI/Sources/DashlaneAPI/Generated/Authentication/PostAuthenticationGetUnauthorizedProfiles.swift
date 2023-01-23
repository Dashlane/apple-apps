import Foundation
extension AppAPIClient.Authentication {
        public struct GetUnauthorizedProfiles {
        public static let endpoint: Endpoint = "/authentication/GetUnauthorizedProfiles"

        public let api: AppAPIClient

                public func callAsFunction(profiles: [AuthenticationProfiles], timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(profiles: profiles)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var getUnauthorizedProfiles: GetUnauthorizedProfiles {
        GetUnauthorizedProfiles(api: api)
    }
}

extension AppAPIClient.Authentication.GetUnauthorizedProfiles {
        struct Body: Encodable {

                public let profiles: [AuthenticationProfiles]
    }
}

extension AppAPIClient.Authentication.GetUnauthorizedProfiles {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public let unauthorizedProfiles: [AuthenticationProfiles]

        public init(unauthorizedProfiles: [AuthenticationProfiles]) {
            self.unauthorizedProfiles = unauthorizedProfiles
        }
    }
}
