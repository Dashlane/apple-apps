import Foundation
import DashTypes

public struct SecureArchiveDBStack {
    public let driver: DatabaseDriver
    public let cryptoEngine: CryptoEngine

    public enum SecureArchiveError: Swift.Error {
        case unreadableArchive
        case noEncryptedData
        case encryptionFailed
    }
    
    public init(driver: DatabaseDriver, cryptoEngine: CryptoEngine) {
        self.driver = driver
        self.cryptoEngine = cryptoEngine
    }

        public func unlock(secureArchiveData data: Data) throws -> Data {
        guard let secureArchiveContent = String(data: data, encoding: .utf8) else {
            throw SecureArchiveError.unreadableArchive
        }

        return try secureArchiveContent
            .parseEncryptedData()
            .decrypt(using: cryptoEngine)
    }

        public func extract(fromBackupContent data: Data) throws -> [PersonalDataRecord] {
        let acceptedTypes = PersonalDataContentType.secureArchiveCases

        return try Array(compressedBackupXMLData: data)
            .filter { acceptedTypes.contains($0.metadata.contentType) }
            .map { (record: PersonalDataRecord) -> PersonalDataRecord in
                var record = record
                record.metadata.markAsPendingUpload()
                return record
            }
    }

        public func save(personalDataRecords: [PersonalDataRecord]) throws {
        try driver.write { db in
            try db.save(personalDataRecords)
        }
    }

                public func `import`(fromSecureArchiveData data: Data) throws  {
        let unlockedArchive = try unlock(secureArchiveData: data)
        let records = try extract(fromBackupContent: unlockedArchive)

        try save(personalDataRecords: records)
    }

        public func exportSecureArchive(to fileURL: URL) throws {
        let acceptedTypes = PersonalDataContentType.secureArchiveCases
        
        let records = try driver.read { db in
            try acceptedTypes.map { type in
                try db.fetchAll(by: type)
            }.joined()
        }
        
        let objectIDs = records.map(\.id.rawValue).joined(separator: ";")
        let encryptedContent = try records
            .makeXML()
            .toQtCompressedData()
            .encrypt(using: cryptoEngine)
            .base64EncodedString()
        
        let secureArchive = """
                -------------------- Dashlane Secured Export ----------------------
                --------------------        Id BEGIN         ----------------------
                \(objectIDs)
                --------------------         Id END          ----------------------
                --------------------       Data BEGIN        ----------------------
                \(encryptedContent)
                --------------------        Data END         ----------------------
                --------------------       Files BEGIN       ----------------------
                --------------------        Files END        ----------------------
                """
        
        try secureArchive.write(to: fileURL, atomically: true, encoding: .utf8)
    }
}

fileprivate extension String {
    func parseEncryptedData() throws -> Data {
        let lines = components(separatedBy: .newlines)
        guard let indexOfDataBeginDelimiter = lines.firstIndex(where: { $0.contains("Data BEGIN") })?.advanced(by: 1),
            let indexOfDataEndDelimiter = lines.firstIndex(where: { $0.contains("Data END") }),
            indexOfDataBeginDelimiter < indexOfDataEndDelimiter else {
                throw SecureArchiveDBStack.SecureArchiveError.noEncryptedData
        }
        
        let base64 = lines[indexOfDataBeginDelimiter..<indexOfDataEndDelimiter].joined()
        guard let data = Data(base64Encoded: base64) else {
            throw SecureArchiveDBStack.SecureArchiveError.noEncryptedData
        }
        return data
    }
}

fileprivate extension PersonalDataContentType {
    static let secureArchiveCases: Set<PersonalDataContentType> = [
        .address,
        .company,
        .email,
        .identity,
        .website,
        .phone,
        .bankAccount,
        .creditCard,
        .driverLicence,
        .taxNumber,
        .idCard,
        .passport,
        .socialSecurityInfo,
        .secureNote,
        .secureFileInfo,
        .secureNoteCategory,
        .credentialCategory,
        .credential
    ]
}
