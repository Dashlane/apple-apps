import CoreTypes
import Foundation
import UserTrackingFoundation

struct ActivityReportsLocalStoreSaver {

  private let workingDirectory: URL
  private let cryptoEngine: CryptoEngine
  private let fileManager = FileManager.default
  private let component: Definition.BrowseComponent

  init(
    workingDirectory: URL,
    component: Definition.BrowseComponent,
    cryptoEngine: CryptoEngine
  ) {
    self.workingDirectory = workingDirectory
    self.cryptoEngine = cryptoEngine
    self.component = component
    self.createLocalDirectories()
  }

  private func createLocalDirectories() {
    try? fileManager.createDirectory(
      at:
        workingDirectory
        .appendingPathComponent(LogCategory.anonymous.rawValue, isDirectory: true)
        .appendingPathComponent(component.rawValue, isDirectory: true),
      withIntermediateDirectories: true,
      attributes: nil)
    try? fileManager.createDirectory(
      at:
        workingDirectory
        .appendingPathComponent(LogCategory.user.rawValue, isDirectory: true)
        .appendingPathComponent(component.rawValue, isDirectory: true),
      withIntermediateDirectories: true,
      attributes: nil)

  }

  public func fetchEntries(max: Int, of category: LogCategory) -> [LogEntry] {
    let path = workingDirectory.appendingPathComponent(category.rawValue, isDirectory: true)
      .appendingPathComponent(component.rawValue, isDirectory: true).path
    let logFilePaths = (try? fileManager.contentsOfDirectory(atPath: path).prefix(max)) ?? []
    return logFilePaths.compactMap { (log: String) -> LogEntry? in
      let filePath = URL(fileURLWithPath: path + "/" + log)
      guard let encryptedContent = try? Data(contentsOf: filePath),
        let content = try? cryptoEngine.decrypt(encryptedContent),
        !content.isEmpty
      else {
        try? fileManager.removeItem(at: filePath)
        return nil
      }
      return LogEntry(url: filePath, data: content)
    }
  }

  public func delete(_ entries: [LogEntry]) {
    entries
      .compactMap({ $0.url })
      .forEach {
        try? self.fileManager.removeItem(at: $0)
      }
  }

  public func store(_ data: Data, category: LogCategory) throws {
    let url =
      workingDirectory
      .appendingPathComponent(category.rawValue, isDirectory: true)
      .appendingPathComponent(component.rawValue, isDirectory: true)
      .appendingPathComponent(UUID().uuidString)
      .appendingPathExtension("log")
    try cryptoEngine.encrypt(data).write(to: url)
  }
}
