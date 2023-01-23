import CorePersonalData
import VaultKit

public protocol ImportServiceProtocol {

    var applicationDatabase: ApplicationDatabase { get }

    func unlock(usingPassword password: String) async throws
    func extract() async throws -> [VaultItem]
    func save(vaultItems: [VaultItem]) async throws

}

extension ImportServiceProtocol {

    func unlock(usingPassword password: String) async throws {
        assertionFailure("Default implementation, shouldn't be used")
    }

}
