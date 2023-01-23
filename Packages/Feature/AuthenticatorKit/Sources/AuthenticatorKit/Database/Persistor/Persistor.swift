import Foundation

public protocol Persistor {
    func load<T>(completion: (T?) -> Void) where T : Decodable, T : Encodable
    func save<T: Codable>(_ items: T) throws
}
