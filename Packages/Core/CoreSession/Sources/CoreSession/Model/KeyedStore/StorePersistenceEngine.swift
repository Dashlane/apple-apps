import Foundation

public protocol StorePersistenceEngine {
    func exists(for key: StoreKey) -> Bool
    func write(_ data: Data?, for key: StoreKey) throws
    func read(for key: StoreKey) throws -> Data
}


extension URL: StorePersistenceEngine {
    public func exists(for key: StoreKey) -> Bool {
        FileManager.default.fileExists(atPath: self.path)
    }
    
    public func write(_ data: Data?, for key: StoreKey) throws {
        if let data = data {
           try data.write(to: self)
        } else {
            try FileManager.default.removeItem(at: self)
        }
    }

    public func read(for key: StoreKey) throws -> Data {
        try Data(contentsOf: self)
    }
}
