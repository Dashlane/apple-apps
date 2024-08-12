import CoreActivityLogs
import CorePersonalData
import DashTypes
import Foundation
import VaultKit

class DashImportService: ImportServiceProtocol {

  enum Step {
    case locked(secureArchive: Data)
    case unlocked(backupContent: Data, password: String)
    case extracted(personalDataRecords: [PersonalDataRecord], password: String)
    case saved
  }

  let applicationDatabase: ApplicationDatabase
  let databaseDriver: DatabaseDriver
  private let activityLogsService: ActivityLogsServiceProtocol

  var step: Step
  private let dataDecoder: PersonalDataDecoder = .init()

  init(
    secureArchiveData: Data, applicationDatabase: ApplicationDatabase,
    databaseDriver: DatabaseDriver, activityLogsService: ActivityLogsServiceProtocol
  ) {
    self.step = .locked(secureArchive: secureArchiveData)
    self.applicationDatabase = applicationDatabase
    self.databaseDriver = databaseDriver
    self.activityLogsService = activityLogsService
  }

  private func decode(from records: [PersonalDataRecord]) throws -> [ImportItem] {
    func decode<T>(_ type: T.Type) throws -> [T] where T: PersonalDataCodable {
      return
        try records
        .filter { $0.metadata.contentType == type.contentType }
        .map { try dataDecoder.decode(type, from: $0) }
    }

    let credentials: [VaultItem] = try decode(Credential.self)
    let secureNotes: [VaultItem] = try decode(SecureNote.self)
    let creditCards: [VaultItem] = try decode(CreditCard.self)
    let bankAccounts: [VaultItem] = try decode(BankAccount.self)
    let identities: [VaultItem] = try decode(Identity.self)
    let emails: [VaultItem] = try decode(Email.self)
    let phones: [VaultItem] = try decode(Phone.self)
    let addresses: [VaultItem] = try decode(Address.self)
    let companies: [VaultItem] = try decode(Company.self)
    let websites: [VaultItem] = try decode(PersonalWebsite.self)
    let passports: [VaultItem] = try decode(Passport.self)
    let idCards: [VaultItem] = try decode(IDCard.self)
    let fiscalInformation: [VaultItem] = try decode(FiscalInformation.self)
    let socialSecurityInformation: [VaultItem] = try decode(SocialSecurityInformation.self)
    let drivingLicences: [VaultItem] = try decode(DrivingLicence.self)
    let passkeys: [VaultItem] = try decode(Passkey.self)
    let collections: [PrivateCollection] = try decode(PrivateCollection.self)

    let vaultItems = [
      credentials,
      secureNotes,
      creditCards,
      bankAccounts,
      identities,
      emails,
      phones,
      addresses,
      companies,
      websites,
      passports,
      idCards,
      fiscalInformation,
      socialSecurityInformation,
      drivingLicences,
      passkeys,
    ]
    .reduce([], +)
    .map { ImportItem(vaultItem: $0) }

    return vaultItems + collections.map { ImportItem(collection: $0) }
  }

  func unlock(usingPassword password: String) async throws {
    guard case .locked(let secureArchiveData) = step else {
      fatalError("The file should be locked before calling \(#function), \(step)")
    }

    return try await withCheckedThrowingContinuation { continuation in
      databaseDriver.unlock(fromSecureArchiveData: secureArchiveData, usingPassword: password) {
        result in
        switch result {
        case .success(let data):
          self.step = .unlocked(backupContent: data, password: password)
          continuation.resume(returning: ())
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  func extract() async throws -> [ImportItem] {
    guard case .unlocked(let backupContent, let password) = step else {
      fatalError("The file should have been unlocked before calling \(#function), \(step)")
    }

    return try await withCheckedThrowingContinuation { continuation in
      databaseDriver.extract(fromBackupContent: backupContent, usingPassword: password) { result in
        switch result {
        case .success(let records):
          self.step = .extracted(personalDataRecords: records, password: password)
          do {
            let vaultItems = try self.decode(from: records)
            continuation.resume(returning: vaultItems)
          } catch {
            continuation.resume(throwing: error)
          }
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  func save(_ vaultItems: [VaultItem], _ collections: [PrivateCollection]) async throws {
    guard case .extracted(let personalDataRecords, let password) = step else {
      fatalError("The file should have been extracted before calling \(#function), \(step)")
    }

    let collections = collections.removeItems(except: vaultItems)

    let result: Result<Void, Error> = await withCheckedContinuation { continuation in
      let (records, collectionsToSave) = recordsAndCollections(
        from: personalDataRecords,
        vaultItems: vaultItems,
        collections: collections
      )

      do {
        try applicationDatabase.save(collectionsToSave)
      } catch {
        continuation.resume(returning: .failure(error))
      }
      databaseDriver.save(personalDataRecords: records, usingPassword: password) { result in
        continuation.resume(returning: result)
      }
    }
    switch result {
    case .success:
      break
    case .failure(let error):
      throw error
    }
  }

  func recordsAndCollections(
    from personalDataRecords: [PersonalDataRecord],
    vaultItems: [VaultItem],
    collections: [PrivateCollection]
  ) -> ([PersonalDataRecord], [PrivateCollection]) {
    let itemRecords = personalDataRecords.intersection(vaultItems)
    let collections = collections.intersection(personalDataRecords)

    if !collections.isEmpty {
      activityLogsService.logImport(collections)
    }

    return itemRecords.generateNewItems(for: collections)
  }
}

extension Array where Element == PersonalDataRecord {
  fileprivate func intersection(_ vaultItems: [VaultItem]) -> [PersonalDataRecord] {
    return filter { record in vaultItems.contains(where: { record.id == $0.id }) }
  }
}

extension Array where Element == PrivateCollection {
  fileprivate func intersection(_ records: [PersonalDataRecord]) -> Self {
    return filter { collection in records.contains(where: { collection.id == $0.id }) }
  }
}

extension DashImportService {
  static var mock: DashImportService {
    return .init(
      secureArchiveData: Data(),
      applicationDatabase: ApplicationDBStack.mock(),
      databaseDriver: InMemoryDatabaseDriver(),
      activityLogsService: .mock())
  }
}

extension Array where Element == PersonalDataRecord {
  fileprivate func generateNewItems(
    for collections: [PrivateCollection]
  ) -> (itemRecords: Self, collections: [PrivateCollection]) {
    var oldToNewIds: [Identifier: Identifier] = [:]

    let itemRecords = self.filter {
      $0.metadata.contentType != .settings || $0.metadata.contentType != .collection
    }
    var newRecords: Self = []

    for itemRecord in itemRecords {
      var record = itemRecord
      let newId = Identifier()
      oldToNewIds[record.id] = newId
      record.metadata.id = newId
      record.metadata.markAsPendingUpload()

      newRecords.append(record)
    }

    let collections = collections.updatedIdentifierAndItemLinks(oldToNewItemIds: oldToNewIds)

    newRecords.append(contentsOf: filter { $0.metadata.contentType == .settings })

    return (newRecords, collections)
  }
}

extension Array where Element == PrivateCollection {
  fileprivate func removeItems(except savedItems: [VaultItem]) -> Self {
    let collections = self

    for var collection in collections {
      collection.items = collection.items.filter { item in
        savedItems.contains(where: { $0.id == item.id })
      }
    }

    return collections
  }

  fileprivate func updatedIdentifierAndItemLinks(oldToNewItemIds: [Identifier: Identifier]) -> Self
  {
    var newCollections: [PrivateCollection] = []

    for collection in self {
      let newIdentifier = Identifier()
      let collectionCopy = PrivateCollection(
        id: newIdentifier,
        name: collection.name,
        creationDatetime: collection.creationDatetime,
        spaceId: collection.spaceId,
        items: Set(
          collection.items.map { item in
            if let newId = oldToNewItemIds[item.id] {
              return .init(id: newId, rawType: item.$type)
            } else {
              return item
            }
          }
        )
      )

      newCollections.append(collectionCopy)
    }

    return newCollections
  }
}
