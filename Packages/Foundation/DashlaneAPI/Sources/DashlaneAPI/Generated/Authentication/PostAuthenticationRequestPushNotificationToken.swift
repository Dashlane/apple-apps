import Foundation
extension UserDeviceAPIClient.Authentication {
        public struct RequestPushNotificationToken {
        public static let endpoint: Endpoint = "/authentication/RequestPushNotificationToken"

        public let api: UserDeviceAPIClient

                public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body()
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var requestPushNotificationToken: RequestPushNotificationToken {
        RequestPushNotificationToken(api: api)
    }
}

extension UserDeviceAPIClient.Authentication.RequestPushNotificationToken {
        struct Body: Encodable {
    }
}

extension UserDeviceAPIClient.Authentication.RequestPushNotificationToken {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public let pushNotificationToken: String

        public init(pushNotificationToken: String) {
            self.pushNotificationToken = pushNotificationToken
        }
    }
}
