import Foundation

public extension NSUbiquitousKeyValueStore {

    func encode<T: Encodable>(_ value: T, forKey key: String) throws {
        let dictionary = try DictionaryEncoder().encode(value)
        set(dictionary, forKey: key)
    }

    func encode<T: Encodable>(_ value: T?, forKey key: String) throws {
        switch value {
        case .some(let value):
            try encode(value, forKey: key)
        case .none:
            removeObject(forKey: key)
        }
    }

    func decode<T: Decodable>(_ type: T.Type, forKey key: String) throws -> T {
        guard let dictionary = dictionary(forKey: key) else {
            throw Error.invalid
        }
        return try DictionaryDecoder().decode(type, from: dictionary)
    }

    func decode<T: Decodable>(_ type: Optional<T>.Type, forKey key: String) throws -> T? {
        guard object(forKey: key) == nil else {
            return try decode(T.self, forKey: key)
        }
        return nil
    }

    private enum Error: Swift.Error {
        case invalid
    }
}
