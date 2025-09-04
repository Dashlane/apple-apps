import CorePersonalData

public protocol ImportServiceProtocol {

  var applicationDatabase: ApplicationDatabase { get }

  func unlock(usingPassword password: String) async throws
  func extract() async throws -> [ImportItem]
  func save(_ vaultItems: [VaultItem], _ collections: [PrivateCollection]) async throws
}

extension ImportServiceProtocol {
  func save(items: ImportableItems) async throws {
    try applicationDatabase.save(items.credentials)
    try applicationDatabase.save(items.secureNotes)
    try applicationDatabase.save(items.creditCards)
    try applicationDatabase.save(items.bankAccounts)
  }
}

extension ImportServiceProtocol {
  func unlock(usingPassword password: String) async throws {
    assertionFailure("Default implementation, shouldn't be used")
  }
}
