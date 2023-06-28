import Foundation
extension UserDeviceAPIClient.Account {
        public struct UpdateContactInfo: APIRequest {
        public static let endpoint: Endpoint = "/account/UpdateContactInfo"

        public let api: UserDeviceAPIClient

                @discardableResult
        public func callAsFunction(contactEmail: String? = nil, contactPhone: String? = nil, country: String? = nil, language: String? = nil, osCountry: String? = nil, osLanguage: String? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(contactEmail: contactEmail, contactPhone: contactPhone, country: country, language: language, osCountry: osCountry, osLanguage: osLanguage)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }

        public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response {
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var updateContactInfo: UpdateContactInfo {
        UpdateContactInfo(api: api)
    }
}

extension UserDeviceAPIClient.Account.UpdateContactInfo {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case contactEmail = "contactEmail"
            case contactPhone = "contactPhone"
            case country = "country"
            case language = "language"
            case osCountry = "osCountry"
            case osLanguage = "osLanguage"
        }

                public let contactEmail: String?

                public let contactPhone: String?

                public let country: String?

                public let language: String?

                public let osCountry: String?

                public let osLanguage: String?
    }
}

extension UserDeviceAPIClient.Account.UpdateContactInfo {
    public typealias Response = Empty?
}
