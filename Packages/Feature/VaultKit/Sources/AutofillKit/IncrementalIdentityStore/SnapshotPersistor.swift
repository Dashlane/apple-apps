import CorePersonalData
import DashTypes
import Foundation
import Logger

public protocol SnapshotPersistor {
  func read() -> SnapshotSummary
  func save(_ itemsSnapshot: SnapshotSummary)
  func remove()
}

public struct FileSnapshotPersistor: SnapshotPersistor {
  let snapshotFileURL: URL
  let cryptoEngine: CryptoEngine
  let logger: Logger

  init(
    folderURL: URL, fileName: String = "snapshot.store", cryptoEngine: CryptoEngine, logger: Logger
  ) {
    self.init(url: folderURL.appending(path: fileName), cryptoEngine: cryptoEngine, logger: logger)
  }

  init(url: URL, cryptoEngine: CryptoEngine, logger: Logger) {
    self.cryptoEngine = cryptoEngine
    self.logger = logger
    self.snapshotFileURL = url
  }

  public func save(_ itemsSnapshot: SnapshotSummary) {
    do {
      let jsonData = try JSONEncoder().encode(itemsSnapshot).encrypt(using: cryptoEngine)
      try jsonData.write(to: snapshotFileURL)
    } catch {
      logger.error("Failed to save snapshot, error: \(error.localizedDescription)")
    }
  }

  public func read() -> SnapshotSummary {
    do {
      guard FileManager.default.fileExists(atPath: snapshotFileURL.path()) else {
        return SnapshotSummary()
      }

      let data = try Data(contentsOf: snapshotFileURL).decrypt(using: cryptoEngine)
      let dict = try JSONDecoder().decode(SnapshotSummary.self, from: data)
      return dict
    } catch {
      logger.error(
        "Failed to read snapshot or it doesn't exist, error: \(error.localizedDescription)")
      return SnapshotSummary()
    }
  }

  public func remove() {
    try? FileManager.default.removeItem(at: snapshotFileURL)
  }
}

public class SnapshotPersistorMock: SnapshotPersistor {
  public var summary: SnapshotSummary

  init(summary: SnapshotSummary = .init(credentials: [], passkeys: [])) {
    self.summary = summary
  }

  public func read() -> SnapshotSummary {
    return summary
  }

  public func save(_ itemsSnapshot: SnapshotSummary) {
    summary = itemsSnapshot
  }

  public func remove() {
    summary = .init(credentials: [], passkeys: [])
  }
}

extension SnapshotPersistor where Self == SnapshotPersistorMock {
  public static func mock(summary: SnapshotSummary = .init()) -> SnapshotPersistorMock {
    SnapshotPersistorMock(summary: summary)
  }
}
