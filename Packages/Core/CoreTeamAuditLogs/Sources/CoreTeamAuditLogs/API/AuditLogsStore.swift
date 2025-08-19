import CoreTypes
import DashlaneAPI
import Foundation

struct AuditLogsStore {
  private let storeURL: URL
  private let cryptoEngine: CryptoEngine

  enum Error: Swift.Error {
    case fileAlreadyExists
  }

  init(storeURL: URL, cryptoEngine: CryptoEngine) {
    self.storeURL = storeURL
    self.cryptoEngine = cryptoEngine
  }

  func store(_ log: TeamAuditLog) throws {
    let fileStoreURL = storeURL.appendingPathComponent(log.uuid)
    let encoded = try JSONEncoder().encode(log)
    guard !FileManager.default.fileExists(atPath: fileStoreURL.path) else {
      throw Error.fileAlreadyExists
    }

    let encryptedData = try cryptoEngine.encrypt(encoded)
    try encryptedData.write(to: fileStoreURL)
  }

  func fetchAll() -> [TeamAuditLog] {
    do {
      let files = try FileManager.default.contentsOfDirectory(atPath: storeURL.path)

      return files.compactMap { fileName in
        let fileURL = storeURL.appendingPathComponent(fileName)
        do {
          let encryptedData = try Data(contentsOf: fileURL)
          let decryptedData = try cryptoEngine.decrypt(encryptedData)

          return try JSONDecoder().decode(TeamAuditLog.self, from: decryptedData)
        } catch {
          try? FileManager.default.removeItem(at: fileURL)
          return nil
        }
      }
    } catch {
      return []
    }
  }

  func removeLogs(withUUIDs uuids: [String]) {
    uuids.forEach { fileName in
      let fileURL = storeURL.appendingPathComponent(fileName)
      try? FileManager.default.removeItem(at: fileURL)
    }
  }
}
