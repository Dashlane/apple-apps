import Foundation
extension AppAPIClient.Account {
        public struct RequestAccountCreation {
        public static let endpoint: Endpoint = "/account/RequestAccountCreation"

        public let api: AppAPIClient

                public func callAsFunction(login: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(login: login)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var requestAccountCreation: RequestAccountCreation {
        RequestAccountCreation(api: api)
    }
}

extension AppAPIClient.Account.RequestAccountCreation {
        struct Body: Encodable {

                public let login: String
    }
}

extension AppAPIClient.Account.RequestAccountCreation {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public enum Exists: String, Codable, Equatable, CaseIterable {
            case yes = "yes"
            case no = "no"
            case noInvalid = "no_invalid"
            case noUnlikely = "no_unlikely"
        }

                public enum EmailValidity: String, Codable, Equatable, CaseIterable {
            case valid = "valid"
            case unlikely = "unlikely"
            case invalid = "invalid"
        }

                public let exists: Exists

                public let accountExists: Bool

                public let emailValidity: EmailValidity

                public let sso: Bool

                public let country: String?

                public let isEuropeanUnion: Bool

                public let ssoIsNitroProvider: Bool?

                public let ssoServiceProviderUrl: String?

        public init(exists: Exists, accountExists: Bool, emailValidity: EmailValidity, sso: Bool, country: String?, isEuropeanUnion: Bool, ssoIsNitroProvider: Bool? = nil, ssoServiceProviderUrl: String? = nil) {
            self.exists = exists
            self.accountExists = accountExists
            self.emailValidity = emailValidity
            self.sso = sso
            self.country = country
            self.isEuropeanUnion = isEuropeanUnion
            self.ssoIsNitroProvider = ssoIsNitroProvider
            self.ssoServiceProviderUrl = ssoServiceProviderUrl
        }
    }
}
