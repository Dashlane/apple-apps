import CSVParser
import CorePersonalData
import Foundation

class CSVImportService: ImportServiceProtocol {

  enum CSVOrigin {
    case keychain
    case lastpass
  }

  let file: Data
  let applicationDatabase: ApplicationDatabase
  let csvOrigin: CSVOrigin
  let personalDataURLDecoder: PersonalDataURLDecoderProtocol

  init(
    file: Data,
    csvOrigin: CSVOrigin,
    applicationDatabase: ApplicationDatabase,
    personalDataURLDecoder: PersonalDataURLDecoderProtocol
  ) {
    self.file = file
    self.csvOrigin = csvOrigin
    self.applicationDatabase = applicationDatabase
    self.personalDataURLDecoder = personalDataURLDecoder
  }

  func extract() async throws -> [ImportItem] {
    let importableItems: ImportableItems
    switch csvOrigin {
    case .lastpass:
      let lastpassItem: [LastpassItem] = try LastpassDecoder.decode(fileContent: file)
      let vaultItems = lastpassItem.compactMap { $0.makeVaultItem(using: personalDataURLDecoder) }
      importableItems = .init(items: vaultItems)
    case .keychain:
      let keychainCredentials: [KeychainCredential] = try KeychainDecoder.decode(fileContent: file)
      importableItems = .init(credentials: keychainCredentials.map(\.credential))
    }

    let deduplicated = importableItems.deduplicate()
    let filtered = applicationDatabase.filterExisting(items: deduplicated)
    return filtered.vaultItems().map { .init(vaultItem: $0) }
  }

  func save(items: ImportableItems) async throws {
    try applicationDatabase.save(items.credentials)
    try applicationDatabase.save(items.secureNotes)
    try applicationDatabase.save(items.creditCards)
    try applicationDatabase.save(items.bankAccounts)
  }

  func save(_ vaultItems: [VaultItem], _ collections: [PrivateCollection]) async throws {
    assertionFailure("Inadmissible action for this kind of import flow")
  }
}

extension CSVImportService {
  static var mock: CSVImportService {
    return .init(
      file: Data(),
      csvOrigin: .keychain,
      applicationDatabase: ApplicationDBStack.mock(),
      personalDataURLDecoder: PersonalDataURLDecoderMock.mock())
  }
}

extension KeychainCredential {
  fileprivate var credential: Credential {
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
