import Foundation
import DashTypes
import SwiftTreats

final public class SettingsManager {
    static let dbName = "Settings"
    static let dbExtension = "sqlite"
    
    static func makeStoreURL(directoryURL: URL) -> URL {
        return directoryURL
            .appendingPathComponent(dbName)
            .appendingPathExtension(dbExtension)
    }
    
    public let logger: Logger
    @Atomic
    private var cachedSettings = [URL: Settings]()

    public var cryptoEngine: CryptoEngine?

    public subscript(directoryURL: URL) -> Settings? {
        get {
            return cachedSettings[Self.makeStoreURL(directoryURL: directoryURL)]
        }
    }
    
    @discardableResult
    public func createSettings(in location: URL) throws -> Settings {
        guard cachedSettings[location] == nil else {
            throw SettingsError.settingsAlreadyExistsFor(directoryURL: location)
        }
        let modelURL = Bundle.settings.url(forResource: "SettingsDataModel", withExtension: "momd")!
        let directoryURL = location
        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            do {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                throw SettingsError.fileSystemErrorAt(path: "\(directoryURL)")
            }
        }
        let storeURL = Self.makeStoreURL(directoryURL: directoryURL)
        let configuration = SettingsConfiguration(modelURL: modelURL,
                                                  storeURL: storeURL)
        let settings = Settings(configuration: configuration, logger: logger)
        settings.delegate = self
        cachedSettings[storeURL] = settings
        return settings
    }

            public func remove(settings: Settings) {
        self.cachedSettings.removeValue(forKey: settings.configuration.storeURL)
    }

                public func erase(settings: Settings) throws {
        self.remove(settings: settings)
        do {
            let storePath = settings.configuration.storeURL.path
            try FileManager.default.removeItem(atPath: storePath)
            
                        let walStorePath = storePath + "-wal"
            try? FileManager.default.removeItem(atPath: walStorePath)
            
            let shmStorePath = storePath + "-shm"
            try? FileManager.default.removeItem(atPath: shmStorePath)
        } catch {
            throw SettingsError.fileSystemErrorAt(path: "\(settings.configuration.storeURL)")
        }
    }
  
        public init(logger: Logger) {
        self.logger = logger
    }
}

extension SettingsManager: SettingsDelegate {

    public func encrypt(data: Data) -> Data? {
        return cryptoEngine?.encrypt(data: data)
    }

    public func decrypt(data: Data) -> Data? {
        return cryptoEngine?.decrypt(data: data)
    }
    
}
