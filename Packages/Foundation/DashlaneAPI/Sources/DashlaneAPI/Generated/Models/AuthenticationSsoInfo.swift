import Foundation

public struct AuthenticationSsoInfo: Codable, Equatable {

    public let serviceProviderUrl: String

        public let isNitroProvider: Bool?

    public let migration: AuthenticationMigration?

    public init(serviceProviderUrl: String, isNitroProvider: Bool? = nil, migration: AuthenticationMigration? = nil) {
        self.serviceProviderUrl = serviceProviderUrl
        self.isNitroProvider = isNitroProvider
        self.migration = migration
    }
}
