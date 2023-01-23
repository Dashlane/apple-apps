import Foundation
extension AppAPIClient.Authentication {
        public struct CompleteLoginWithAuthTicket {
        public static let endpoint: Endpoint = "/authentication/CompleteLoginWithAuthTicket"

        public let api: AppAPIClient

                public func callAsFunction(login: String, deviceAccessKey: String, authTicket: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(login: login, deviceAccessKey: deviceAccessKey, authTicket: authTicket)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var completeLoginWithAuthTicket: CompleteLoginWithAuthTicket {
        CompleteLoginWithAuthTicket(api: api)
    }
}

extension AppAPIClient.Authentication.CompleteLoginWithAuthTicket {
        struct Body: Encodable {

                public let login: String

                public let deviceAccessKey: String

                public let authTicket: String
    }
}

extension AppAPIClient.Authentication.CompleteLoginWithAuthTicket {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public let remoteKeys: [AuthenticationCompleteRemoteKeys]?

                public let serverKey: String?

                public let ssoServerKey: String?

        public init(remoteKeys: [AuthenticationCompleteRemoteKeys]? = nil, serverKey: String? = nil, ssoServerKey: String? = nil) {
            self.remoteKeys = remoteKeys
            self.serverKey = serverKey
            self.ssoServerKey = ssoServerKey
        }
    }
}
