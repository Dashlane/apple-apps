import CoreTypes
import DashlaneAPI
import Foundation
import UserTrackingFoundation

public typealias LogCategory = StyxDataAPIClient.LogCategory

public struct LogEntry: Hashable {
  public let url: URL?
  public let data: Data
}

public struct ActivityReportsLocalStore {

  private let workingDirectory: URL
  private let cryptoEngine: CryptoEngine
  private let fileManager = FileManager.default

  private enum Mode {
    case batchSave(ActivityReportsLocalStoreBatcher)
    case saveDirectly(ActivityReportsLocalStoreSaver)
  }

  private var mode: Mode

  public init(
    workingDirectory: URL,
    cryptoEngine: CryptoEngine,
    component: Definition.BrowseComponent,
    batchLogs: Bool
  ) {
    self.workingDirectory = workingDirectory
    self.cryptoEngine = cryptoEngine
    let fileSaver = ActivityReportsLocalStoreSaver(
      workingDirectory: workingDirectory, component: component, cryptoEngine: cryptoEngine)
    if batchLogs {
      self.mode = .batchSave(ActivityReportsLocalStoreBatcher(saver: fileSaver))
    } else {
      self.mode = .saveDirectly(fileSaver)
    }
  }

  public func fetchEntries(max: Int, of category: LogCategory) async throws -> [LogEntry] {
    let entries: [LogEntry]
    switch mode {
    case let .saveDirectly(saver):
      entries = saver.fetchEntries(max: max, of: category)
    case let .batchSave(batcher):
      entries = try await batcher.fetchEntries(max: max, of: category)
    }
    return entries
  }

  public func delete(_ entries: [LogEntry]) async {
    entries
      .compactMap({ $0.url })
      .forEach {
        try? self.fileManager.removeItem(at: $0)
      }
  }

  public func store(_ data: Data, category: LogCategory) async throws {
    switch mode {
    case let .saveDirectly(saver):
      return try saver.store(data, category: category)
    case let .batchSave(batcher):
      return try await batcher.store(data, category: category)
    }
  }
}
