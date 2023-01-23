import Foundation
import JavaScriptCore
import DashTypes

@objc private protocol StorageExport: JSExport {
    func get(_ name: String) -> Any?
    func getRaw(_ name: String) -> Any?
    func set(_ name: String, _ value: Any)
    func setRaw(_ name: String, _ value: Any)
    func deleteRaw(_ name: String)
}

protocol UnencryptedRawStorage {
    func object(forKey: String) -> Any?
    func set(_ value: Any?, forKey: String)
    func removeObject(forKey: String)
}

extension UserDefaults: UnencryptedRawStorage { }

final class ExportedStorage: NSObject, StorageExport {
    
    let endpoint: Endpoint
    private let logger: Logger?
    let storage: UnencryptedRawStorage = UserDefaults.standard

    init(endpoint: Endpoint, logger: Logger?) {
        self.endpoint = endpoint
        self.logger = logger
        super.init()
    }
    
    private func getKey(for name: String) -> String {
        return "\(endpoint).\(name)"
    }
    
    func get(_ name: String) -> Any? {
        let key = getKey(for: name)
        let value = storage.object(forKey: key)
        logger?.debug("GET \(key) => \(String(describing: value))")
        return value
    }
    
    func getRaw(_ name: String) -> Any? {
        return self.get(name)
    }
    
    func set(_ name: String, _ value: Any)  {
        let key = getKey(for: name)
        logger?.debug("SET \(key) \(value)")
        storage.set(value, forKey: key)
    }
    
   func setRaw(_ name: String, _ value: Any)  {
         self.set(name,value)
    }
    
    func deleteRaw(_ name: String)  {
        let key = getKey(for: name)
        logger?.debug("\(key)")
        storage.removeObject(forKey: key)
    }
}
