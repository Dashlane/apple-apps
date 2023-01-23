import CSVParser
import DashlaneAppKit
import Foundation
import CorePersonalData
import VaultKit

private extension KeychainCredential {

    var credential: Credential {
        return Credential(
            login: username,
            title: title,
            password: password,
            email: username,
            otpURL: otpAuth,
            url: url,
            note: notes
        )
    }

}

class KeychainImportService: ImportServiceProtocol {

    let file: Data
    let applicationDatabase: ApplicationDatabase

    init(file: Data, applicationDatabase: ApplicationDatabase) {
        self.file = file
        self.applicationDatabase = applicationDatabase
    }

    func extract() async throws -> [VaultItem] {
        let keychainCredentials: [KeychainCredential] = try KeychainDecoder.decode(fileContent: file)
        let vaultItems: [VaultItem] = keychainCredentials.map(\.credential)
        return vaultItems
    }

    func save(vaultItems: [VaultItem]) async throws {
                        let credentials: [Credential] = vaultItems.compactMap { $0 as? Credential }
        try applicationDatabase.save(credentials)
    }

}

extension KeychainImportService {
    static var mock: KeychainImportService {
        return .init(file: Data(), applicationDatabase: ApplicationDBStack.mock())
    }
}
