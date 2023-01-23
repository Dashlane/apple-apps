import Foundation
import DashTypes

public protocol SourceSessionStoreItem: SessionStoreItem {
        var exists: Bool { get }
        func clear()
}

public class MigrationStoreProvider<Source: SessionStoreProviderProtocol, Target: SessionStoreProviderProtocol> : SessionStoreProviderProtocol where Source.LoginStore: SourceSessionStoreItem, Source.InfoStore: SourceSessionStoreItem, Source.LocalKeyStore: SourceSessionStoreItem, Source.KeysStore: SourceSessionStoreItem {
    let source: Source
    let target: Target
    
    public struct StoreItem<Source: SourceSessionStoreItem, Target: SessionStoreItem>: SessionStoreItem where Source.Item == Target.Item {
        let source: Source?
        let target: Target
        
        public func load() throws -> Target.Item {
            if let source = source, source.exists {
                let item = try source.load()
                try target.save(item)
                let value = try target.load()
                source.clear()
                return value
            } else {
                return try target.load()
            }
        }
        
        public func save(_ data: Target.Item) throws {
            try target.save(data)
        }
    }
    
    public init(source: Source, target: Target) {
        self.source = source
        self.target = target
    }
    
    public func currentLoginStore(forContainerURL baseURL: URL) throws -> StoreItem<Source.LoginStore, Target.LoginStore> {
        try StoreItem(source: source.currentLoginStore(forContainerURL: baseURL),
                      target: target.currentLoginStore(forContainerURL: baseURL))
    }
    
    public func infoStore(for login: Login, directory: SessionDirectory) throws -> StoreItem<Source.InfoStore, Target.InfoStore> {
        try StoreItem(source: try? source.infoStore(for: login, directory: directory),
                      target: target.infoStore(for: login, directory: directory))
    }
    
    public func encryptedLocalKeyStore(for login: Login, info: SessionInfo, directory: SessionDirectory) throws -> StoreItem<Source.LocalKeyStore, Target.LocalKeyStore> {
        try StoreItem(source: try? source.encryptedLocalKeyStore(for: login, info: info, directory: directory),
                      target: target.encryptedLocalKeyStore(for: login, info: info, directory: directory))
    }
    
    public func keysStore(for login: Login, directory: SessionDirectory, using engineSet: StoreCryptoEngineSet, info: SessionInfo) throws -> StoreItem<Source.KeysStore, Target.KeysStore> {
        try StoreItem(source: try? source.keysStore(for: login, directory: directory, using: engineSet, info: info),
                      target: target.keysStore(for: login, directory: directory, using: engineSet, info: info))
    }
}
