import Foundation
extension UserDeviceAPIClient.Authenticator {
        public struct GetPendingRequests: APIRequest {
        public static let endpoint: Endpoint = "/authenticator/GetPendingRequests"

        public let api: UserDeviceAPIClient

                public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body()
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var getPendingRequests: GetPendingRequests {
        GetPendingRequests(api: api)
    }
}

extension UserDeviceAPIClient.Authenticator.GetPendingRequests {
        public struct Body: Encodable {
    }
}

extension UserDeviceAPIClient.Authenticator.GetPendingRequests {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case requests = "requests"
        }

                public let requests: [Requests]

                public struct Requests: Codable, Equatable {

            private enum CodingKeys: String, CodingKey {
                case id = "id"
                case login = "login"
                case validity = "validity"
                case device = "device"
                case location = "location"
            }

                        public let id: String

                        public let login: String

            public let validity: Validity

            public let device: Device

            public let location: Location

                        public struct Validity: Codable, Equatable {

                private enum CodingKeys: String, CodingKey {
                    case startDate = "startDate"
                    case expireDate = "expireDate"
                }

                                public let startDate: Int

                                public let expireDate: Int

                public init(startDate: Int, expireDate: Int) {
                    self.startDate = startDate
                    self.expireDate = expireDate
                }
            }

                        public struct Device: Codable, Equatable {

                private enum CodingKeys: String, CodingKey {
                    case name = "name"
                    case platform = "platform"
                    case vendor = "vendor"
                }

                                public let name: String?

                                public let platform: String?

                                public let vendor: String?

                public init(name: String? = nil, platform: String? = nil, vendor: String? = nil) {
                    self.name = name
                    self.platform = platform
                    self.vendor = vendor
                }
            }

                        public struct Location: Codable, Equatable {

                private enum CodingKeys: String, CodingKey {
                    case coordinate = "coordinate"
                    case countryCode = "countryCode"
                }

                public let coordinate: Coordinate?

                                public let countryCode: String?

                                public struct Coordinate: Codable, Equatable {

                    private enum CodingKeys: String, CodingKey {
                        case longitude = "longitude"
                        case latitude = "latitude"
                    }

                    public let longitude: Int

                    public let latitude: Int

                    public init(longitude: Int, latitude: Int) {
                        self.longitude = longitude
                        self.latitude = latitude
                    }
                }

                public init(coordinate: Coordinate? = nil, countryCode: String? = nil) {
                    self.coordinate = coordinate
                    self.countryCode = countryCode
                }
            }

            public init(id: String, login: String, validity: Validity, device: Device, location: Location) {
                self.id = id
                self.login = login
                self.validity = validity
                self.device = device
                self.location = location
            }
        }

        public init(requests: [Requests]) {
            self.requests = requests
        }
    }
}
