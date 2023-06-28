import Foundation
extension UserDeviceAPIClient.Useractivity {
        public struct Create: APIRequest {
        public static let endpoint: Endpoint = "/useractivity/Create"

        public let api: UserDeviceAPIClient

                @discardableResult
        public func callAsFunction(relativeStart: Int, relativeEnd: Int, userActivity: UseractivityCreateActivity, teamActivity: TeamActivity? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(relativeStart: relativeStart, relativeEnd: relativeEnd, userActivity: userActivity, teamActivity: teamActivity)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }

        public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response {
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var create: Create {
        Create(api: api)
    }
}

extension UserDeviceAPIClient.Useractivity.Create {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case relativeStart = "relativeStart"
            case relativeEnd = "relativeEnd"
            case userActivity = "userActivity"
            case teamActivity = "teamActivity"
        }

                public let relativeStart: Int

                public let relativeEnd: Int

        public let userActivity: UseractivityCreateActivity

        public let teamActivity: TeamActivity?
    }

        public struct TeamActivity: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case teamId = "teamId"
            case activity = "activity"
        }

                public let teamId: Int

        public let activity: UseractivityCreateActivity

        public init(teamId: Int, activity: UseractivityCreateActivity) {
            self.teamId = teamId
            self.activity = activity
        }
    }
}

extension UserDeviceAPIClient.Useractivity.Create {
    public typealias Response = Empty?
}
