import Foundation
import DashTypes

struct ActivityReportsLocalStoreSaver {

        private let workingDirectory: URL
    private let cryptoEngine: CryptoEngine
    private let fileManager = FileManager.default

        init(workingDirectory: URL,
         cryptoEngine: CryptoEngine) {
        self.workingDirectory = workingDirectory
        self.cryptoEngine = cryptoEngine
        self.createLocalDirectories()
    }

    private func createLocalDirectories() {
        try? fileManager.createDirectory(at: workingDirectory.appendingPathComponent(LogCategory.anonymous.rawValue),
                                         withIntermediateDirectories: true,
                                         attributes: nil)
        try? fileManager.createDirectory(at: workingDirectory.appendingPathComponent(LogCategory.user.rawValue),
                                         withIntermediateDirectories: true,
                                         attributes: nil)

    }

            public func fetchEntries(max: Int, of category: LogCategory) -> [LogEntry] {
        let path = workingDirectory.appendingPathComponent(category.rawValue, isDirectory: true).path
        let logFilePaths = (try? fileManager.contentsOfDirectory(atPath: path).prefix(max)) ?? []
        return logFilePaths.compactMap { (log: String) -> LogEntry? in
            let filePath = URL(fileURLWithPath: path + "/" + log)
            guard let encryptedContent = try? Data(contentsOf: filePath),
                  let content = cryptoEngine.decrypt(data: encryptedContent),
                  !content.isEmpty else {
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
        let url = workingDirectory
            .appendingPathComponent(category.rawValue, isDirectory: true)
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("log")
        try cryptoEngine.encrypt(data: data)?.write(to: url)
    }
}
