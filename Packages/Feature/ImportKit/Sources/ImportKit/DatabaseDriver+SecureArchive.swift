import CoreCrypto
import CorePersonalData
import DashTypes
import Foundation

extension DatabaseDriver {
  private func makeSecureArchiveStack(password: String) throws -> SecureArchiveDBStack {
    let config = CryptoConfiguration.default
    let cryptoEngine = try CryptoConfiguration.default
      .makeCryptoEngine(secret: .password(password), fixedSalt: config.makeDerivationSalt())

    return SecureArchiveDBStack(driver: self, cryptoEngine: cryptoEngine)
  }

  public func exportSecureArchive(
    usingPassword password: String, to fileURL: URL, spaceId: String? = nil,
    filter: (PersonalDataRecord) -> Bool
  ) throws -> URL {
    let stack = try makeSecureArchiveStack(password: password)
    try stack.exportSecureArchive(to: fileURL, spaceId: spaceId, isIncludedIn: filter)
    return fileURL
  }

  public func unlock(
    fromSecureArchiveData data: Data,
    usingPassword password: String,
    _ completion: @escaping (Result<Data, Error>) -> Void
  ) {
    do {
      let stack = try makeSecureArchiveStack(password: password)
      DispatchQueue.global(qos: .userInitiated).async {
        let result = Result {
          try stack.unlock(secureArchiveData: data)
        }

        DispatchQueue.main.async {
          return completion(result)
        }
      }
    } catch {
      return completion(.failure(error))
    }
  }

  public func extract(
    fromBackupContent data: Data,
    usingPassword password: String,
    _ completion: @escaping (Result<[PersonalDataRecord], Error>) -> Void
  ) {
    do {
      let stack = try makeSecureArchiveStack(password: password)
      DispatchQueue.global(qos: .userInitiated).async {
        let result = Result {
          try stack.extract(fromBackupContent: data)
        }

        DispatchQueue.main.async {
          return completion(result)
        }
      }
    } catch {
      return completion(.failure(error))
    }
  }

  public func save(
    personalDataRecords records: [PersonalDataRecord],
    usingPassword password: String,
    _ completion: @escaping (Result<Void, Error>) -> Void
  ) {
    do {
      let stack = try makeSecureArchiveStack(password: password)
      DispatchQueue.global(qos: .userInitiated).async {
        let result = Result {
          try stack.save(personalDataRecords: records)
        }

        DispatchQueue.main.async {
          return completion(result)
        }
      }
    } catch {
      return completion(.failure(error))
    }
  }

  public func `import`(
    fromSecureArchiveData data: Data, usingPassword password: String,
    _ completion: @escaping (Result<Void, Error>) -> Void
  ) {
    do {
      let stack = try makeSecureArchiveStack(password: password)
      DispatchQueue.global(qos: .userInitiated).async {
        let result = Result {
          try stack.import(fromSecureArchiveData: data)
        }

        DispatchQueue.main.async {
          completion(result)
        }
      }
    } catch {
      completion(.failure(error))
    }
  }
}
