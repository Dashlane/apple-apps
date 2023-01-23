import Foundation

extension UserEvent {

public struct `MigrateCrypto`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`newCrypto`: Definition.CryptoAlgorithm, `previousCrypto`: Definition.CryptoAlgorithm, `status`: Definition.CryptoMigrationStatus, `type`: Definition.CryptoMigrationType) {
self.newCrypto = newCrypto
self.previousCrypto = previousCrypto
self.status = status
self.type = type
}
public let name = "migrate_crypto"
public let newCrypto: Definition.CryptoAlgorithm
public let previousCrypto: Definition.CryptoAlgorithm
public let status: Definition.CryptoMigrationStatus
public let type: Definition.CryptoMigrationType
}
}
