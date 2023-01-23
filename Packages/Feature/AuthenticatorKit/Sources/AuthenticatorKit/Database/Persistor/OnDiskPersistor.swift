import Foundation
import CoreIPC

struct OnDiskPersistor: Persistor {
    
    let persistedURL: URL
    private let coordinator = NSFileCoordinator()
    let coder: IPCMessageCoder
    init(persistedURL: URL, coder: IPCMessageCoder) {
        self.persistedURL = persistedURL
        self.coder = coder
    }
    
    func load<T>(completion: (T?) -> Void) where T : Decodable, T : Encodable {
        if (!FileManager.default.fileExists(atPath: persistedURL.path)) {
            completion(nil)
        }
        coordinator.coordinate(readingItemAt: persistedURL, options: [], error: nil) { readURL in
            guard let itemsData = try? Data(contentsOf: readURL) else {
                completion(nil)
                return
            }
            do {
                let result: T = try coder.decode(itemsData)
                completion(result)
            } catch {
                print("Couldn't decode items: \(error)")
                completion(nil)
            }
        }
    }
    
    func save<T>(_ items: T) throws where T : Decodable, T : Encodable {
        var result: Result<Void, Error> = .failure(URLError(.unknown))
        coordinator.coordinate(writingItemAt: persistedURL, options: [], error: nil, byAccessor: { url in
            result = Result {
                let data = try coder.encode(items)
                try data.write(to: persistedURL)
            }
        })
        return try result.get()
    }
}

public struct PersistedItems<T: Codable>: Codable {
    let items: [T]
    
    public init(items: [T]) {
        self.items = items
    }
}
