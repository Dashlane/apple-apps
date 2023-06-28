import Foundation
extension UserDeviceAPIClient.Icons {
        public struct GetIcons: APIRequest {
        public static let endpoint: Endpoint = "/icons/GetIcons"

        public let api: UserDeviceAPIClient

                public func callAsFunction(hashes: [String], timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(hashes: hashes)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var getIcons: GetIcons {
        GetIcons(api: api)
    }
}

extension UserDeviceAPIClient.Icons.GetIcons {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case hashes = "hashes"
        }

                public let hashes: [String]
    }
}

extension UserDeviceAPIClient.Icons.GetIcons {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case icons = "icons"
        }

                public let icons: [Icons]

                public struct Icons: Codable, Equatable {

                        public enum Validity: String, Codable, Equatable, CaseIterable {
                case expired = "expired"
                case invalid = "invalid"
                case valid = "valid"
                case pending = "pending"
            }

            private enum CodingKeys: String, CodingKey {
                case hash = "hash"
                case validity = "validity"
                case backgroundColor = "backgroundColor"
                case mainColor = "mainColor"
                case url = "url"
            }

                        public let hash: String

                        public let validity: Validity

            public let backgroundColor: String?

            public let mainColor: String?

                        public let url: String?

            public init(hash: String, validity: Validity, backgroundColor: String? = nil, mainColor: String? = nil, url: String? = nil) {
                self.hash = hash
                self.validity = validity
                self.backgroundColor = backgroundColor
                self.mainColor = mainColor
                self.url = url
            }
        }

        public init(icons: [Icons]) {
            self.icons = icons
        }
    }
}
