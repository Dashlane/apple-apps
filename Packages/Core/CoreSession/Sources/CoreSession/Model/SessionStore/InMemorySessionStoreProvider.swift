import Foundation
import DashTypes

public class InMemorySessionStoreProvider: SessionStoreProviderProtocol {
    public class LoginStore: SourceSessionStoreItem {
        var login: Login? = nil
        public var exists: Bool {
            return login != nil
        }
        
        public func load() throws -> Login? {
            return login
        }
        
        public func save(_ login: Login?) throws {
            self.login = login
        }
        
        public func clear() {
            self.login = nil
        }
    }
    
    class SharedStore<T> {
        var values: [Login: T] = [:]
        
        subscript(_ login: Login) -> T? {
            get {
                values[login]
            } set {
                values[login] = newValue
            }
        }
    }
    
    public struct InMemorySessionStore<T>: SourceSessionStoreItem {
        enum Error: Swift.Error {
            case emptyStorage
        }
        
        let login: Login
        let store: SharedStore<T>
        
        public var exists: Bool {
            return  store[login] != nil
        }
        
        public func load() throws -> T {
            guard let value = store[login] else {
                throw Error.emptyStorage
            }
            return value
        }
        
        public func save(_ data: T) throws {
            store[login] = data
        }
        
        public func clear() {
            store[login] = nil
        }
    }
    
    let loginStore = LoginStore()
    let infoStore = SharedStore<SessionInfo>()
    let localKeyStore = SharedStore<Data>()
    let keysStore = SharedStore<SessionSecureKeys>()

    public init() {
        
    }
    
    public func currentLoginStore(forContainerURL baseURL: URL) throws -> LoginStore {
        loginStore
    }
    
    public func infoStore(for login: Login, directory: SessionDirectory) throws -> InMemorySessionStore<SessionInfo> {
        InMemorySessionStore(login: login, store: infoStore)
    }
    
    public func encryptedLocalKeyStore(for login: Login, info: SessionInfo, directory: SessionDirectory) throws -> InMemorySessionStore<Data> {
        InMemorySessionStore(login: login, store: localKeyStore)
    }
    
    public func keysStore(for login: Login, directory: SessionDirectory, using engineSet: StoreCryptoEngineSet, info: SessionInfo) throws -> InMemorySessionStore<SessionSecureKeys> {
        InMemorySessionStore(login: login, store: keysStore)
    }
}
