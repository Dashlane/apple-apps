import Foundation
import DashTypes
import DashlaneAPI

public typealias LogCategory = StyxDataAPIClient.LogCategory

public struct ActivityReportsLocalStore {
    private let workingDirectory: URL
    private let cryptoEngine: CryptoEngine
    private let fileManager = FileManager.default
    
    public struct Entry {
        public let url: URL
        public let data: Data
    }
    
    public init(workingDirectory: URL,
                cryptoEngine: CryptoEngine) {
        self.workingDirectory = workingDirectory
        self.cryptoEngine = cryptoEngine
        self.createLocalDirectories()
    }
    
    func createLocalDirectories() {
        try? fileManager.createDirectory(at: workingDirectory.appendingPathComponent(LogCategory.anonymous.rawValue),
                                         withIntermediateDirectories: true,
                                         attributes: nil)
        try? fileManager.createDirectory(at: workingDirectory.appendingPathComponent(LogCategory.user.rawValue),
                                         withIntermediateDirectories: true,
                                         attributes: nil)
        
    }
    
        public func fetchEntries(max: Int, of category: LogCategory) -> [Entry] {
        let logFilePaths = enumerateLogFiles(at: workingDirectory.appendingPathComponent(category.rawValue, isDirectory: true)).prefix(max)
        return logFilePaths.compactMap {
            if let encryptedContent = try? Data(contentsOf: $0),
            let content = cryptoEngine.decrypt(data: encryptedContent) {
                            return Entry(url: $0, data: content)
            }
            return nil
        }
    }
    
    public func delete(entries: [Entry]) {
        entries.forEach {
            try? self.fileManager.removeItem(at: $0.url)
        }
    }
    
    public func store(data: Data, category: LogCategory) throws {
        let url = workingDirectory
            .appendingPathComponent(category.rawValue, isDirectory: true)
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("log")
        try cryptoEngine.encrypt(data: data)?.write(to: url)
    }
    
                private func enumerateLogFiles(at url: URL) -> [URL] {
        guard let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) else {
            return []
        }
        return enumerator.compactMap { $0 as? URL }.filter {
            $0.pathExtension == "log"
        }
    }
}
