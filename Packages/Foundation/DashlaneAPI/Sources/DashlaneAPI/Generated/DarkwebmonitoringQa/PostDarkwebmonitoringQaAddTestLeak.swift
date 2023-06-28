import Foundation
extension AppAPIClient.DarkwebmonitoringQa {
        public struct AddTestLeak: APIRequest {
        public static let endpoint: Endpoint = "/darkwebmonitoring-qa/AddTestLeak"

        public let api: AppAPIClient

                @discardableResult
        public func callAsFunction(leak: Leak, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(leak: leak)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var addTestLeak: AddTestLeak {
        AddTestLeak(api: api)
    }
}

extension AppAPIClient.DarkwebmonitoringQa.AddTestLeak {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case leak = "leak"
        }

        public let leak: Leak
    }

        public struct Leak: Codable, Equatable {

                public enum Types: String, Codable, Equatable, CaseIterable {
            case phone = "phone"
            case password = "password"
            case email = "email"
            case username = "username"
            case creditcard = "creditcard"
            case address = "address"
            case ip = "ip"
            case geolocation = "geolocation"
            case personalinfo = "personalinfo"
            case social = "social"
        }

        private enum CodingKeys: String, CodingKey {
            case uuid = "uuid"
            case fields = "fields"
            case types = "types"
            case email = "email"
        }

        public let uuid: String

        public let fields: [Fields]

        public let types: [Types]

        public let email: String

                public struct Fields: Codable, Equatable {

                        public enum Field: String, Codable, Equatable, CaseIterable {
                case password = "password"
                case passwordPlaintext = "password_plaintext"
                case salt = "salt"
                case passwordType = "password_type"
                case email = "email"
                case username = "username"
                case phone = "phone"
                case address1 = "address_1"
                case address2 = "address_2"
                case city = "city"
                case country = "country"
                case county = "county"
                case state = "state"
                case postalCode = "postal_code"
                case ccBin = "cc_bin"
                case ccCode = "cc_code"
                case ccExpiration = "cc_expiration"
                case ccLastFour = "cc_last_four"
                case ccType = "cc_type"
                case ipAddresses = "ip_addresses"
                case geolocation = "geolocation"
                case age = "age"
                case fullName = "full_name"
                case gender = "gender"
                case language = "language"
                case timezone = "timezone"
                case dob = "dob"
                case socialAim = "social_aim"
                case socialFacebook = "social_facebook"
                case socialGithub = "social_github"
                case socialGoogle = "social_google"
                case socialIcq = "social_icq"
                case socialInstagram = "social_instagram"
                case socialLinkedin = "social_linkedin"
                case socialMsn = "social_msn"
                case socialMyspace = "social_myspace"
                case socialOther = "social_other"
                case socialSkype = "social_skype"
                case socialTelegram = "social_telegram"
                case socialTwitter = "social_twitter"
                case socialWhatsapp = "social_whatsapp"
                case socialYahoo = "social_yahoo"
                case socialYoutube = "social_youtube"
            }

            private enum CodingKeys: String, CodingKey {
                case field = "field"
                case value = "value"
            }

            public let field: Field

            public let value: String

            public init(field: Field, value: String) {
                self.field = field
                self.value = value
            }
        }

        public init(uuid: String, fields: [Fields], types: [Types], email: String) {
            self.uuid = uuid
            self.fields = fields
            self.types = types
            self.email = email
        }
    }
}

extension AppAPIClient.DarkwebmonitoringQa.AddTestLeak {
    public typealias Response = Empty?
}
