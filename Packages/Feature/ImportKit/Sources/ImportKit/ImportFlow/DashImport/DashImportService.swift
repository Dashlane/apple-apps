import DashlaneAppKit
import Foundation
import CorePersonalData
import VaultKit

class DashImportService: ImportServiceProtocol {

    private enum Step {
        case locked(secureArchive: Data)
        case unlocked(backupContent: Data, password: String)
        case extracted(personalDataRecords: [PersonalDataRecord], password: String)
        case saved
    }

    let applicationDatabase: ApplicationDatabase
    let databaseDriver: DatabaseDriver

    private var step: Step
    private let dataDecoder: PersonalDataDecoder = .init()

    init(secureArchiveData: Data, applicationDatabase: ApplicationDatabase, databaseDriver: DatabaseDriver) {
        self.step = .locked(secureArchive: secureArchiveData)
        self.applicationDatabase = applicationDatabase
        self.databaseDriver = databaseDriver
    }

    private func decode(from records: [PersonalDataRecord]) throws -> [VaultItem] {
        func decode<T>(_ type: T.Type) throws -> [T] where T: PersonalDataCodable {
            return try records
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

        return [credentials, secureNotes, creditCards, bankAccounts, identities, emails, phones, addresses,
                companies, websites, passports, idCards, fiscalInformation, socialSecurityInformation, drivingLicences
        ].reduce([], { $0 + $1 })
    }

    func unlock(usingPassword password: String) async throws {
        guard case .locked(let secureArchiveData) = step else {
            fatalError("The file should be locked before calling \(#function), \(step)")
        }

        return try await withCheckedThrowingContinuation { continuation in
            databaseDriver.unlock(fromSecureArchiveData: secureArchiveData, usingPassword: password) { result in
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

    func extract() async throws -> [VaultItem] {
        guard case .unlocked(let backupContent, let password) = step else {
            fatalError("The file should have been unlocked before calling \(#function), \(step)")
        }

        return try await withCheckedThrowingContinuation { continuation in
            databaseDriver.extract(fromBackupContent: backupContent, usingPassword: password) { result in
                switch result {
                case .success(let records):
                    self.step = .extracted(personalDataRecords: records, password: password)
                    do {
                        let vaultsItems = try self.decode(from: records)
                        continuation.resume(returning: vaultsItems)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func save(_ vaultItems: [VaultItem]) async throws {
        guard case .extracted(let personalDataRecords, let password) = step else {
            fatalError("The file should have been extracted before calling \(#function), \(step)")
        }

        let result: Result<Void, Error> = await withCheckedContinuation { continuation in
            let records = personalDataRecords.intersection(vaultItems)
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

}

private extension Array where Element == PersonalDataRecord {
    func intersection(_ vaultItems: [VaultItem]) -> [PersonalDataRecord] {
        return filter { record in vaultItems.contains(where: { record.id == $0.id }) }
    }
}

extension DashImportService {
    static var mock: DashImportService {
        return .init(secureArchiveData: Data(), applicationDatabase: ApplicationDBStack.mock(), databaseDriver: InMemoryDatabaseDriver())
    }
}
