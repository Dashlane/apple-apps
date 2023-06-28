import Foundation
extension AppAPIClient.Features {
        public struct ListAvailableFeatureFlips: APIRequest {
        public static let endpoint: Endpoint = "/features/ListAvailableFeatureFlips"

        public let api: AppAPIClient

                public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body()
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var listAvailableFeatureFlips: ListAvailableFeatureFlips {
        ListAvailableFeatureFlips(api: api)
    }
}

extension AppAPIClient.Features.ListAvailableFeatureFlips {
        public struct Body: Encodable {
    }
}

extension AppAPIClient.Features.ListAvailableFeatureFlips {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case features = "features"
        }

                public let features: [Features]

                public struct Features: Codable, Equatable {

            private enum CodingKeys: String, CodingKey {
                case name = "name"
                case archived = "archived"
            }

            public let name: String

            public let archived: Bool

            public init(name: String, archived: Bool) {
                self.name = name
                self.archived = archived
            }
        }

        public init(features: [Features]) {
            self.features = features
        }
    }
}
