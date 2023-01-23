import Foundation

public final class DictionaryDecoder {

    public var userInfo: [CodingUserInfoKey: Any]

    public init () {
        self.userInfo = [:]
    }

    public func decode<T: Decodable>(_ type: T.Type, from dictionary: [String: Any]) throws -> T {
        let decoder = Decoder(codingPath: [], storage: .keyed(dictionary), userInfo: userInfo)
        return try T.init(from: decoder)
    }

    public func decode<T: Decodable>(_ type: T.Type, from array: [Any]) throws -> T {
        let decoder = Decoder(codingPath: [], storage: .unkeyed(array), userInfo: userInfo)
        return try T.init(from: decoder)
    }
}

private extension DictionaryDecoder {

    enum Error: Swift.Error {
        case missingValue(at: [CodingKey])
        case unexpectedValue(at: [CodingKey])
    }

    struct Decoder: Swift.Decoder {

        let storage: Storage
        let codingPath: [CodingKey]
        let userInfo: [CodingUserInfoKey: Any]

        init(codingPath: [CodingKey], storage: Storage, userInfo: [CodingUserInfoKey: Any]) {
            self.codingPath = codingPath
            self.storage = storage
            self.userInfo = userInfo
        }

        func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
            guard let keyedStorage = storage.keyedStorage()  else {
                throw Error.unexpectedValue(at: codingPath)
            }

            let keyed = KeyedContainer<Key>(codingPath: codingPath,
                                            storage: keyedStorage,
                                            userInfo: userInfo)
            return KeyedDecodingContainer<Key>(keyed)
        }

        func unkeyedContainer() throws -> UnkeyedDecodingContainer {
            guard let unkeyedStorage = storage.unkeyedStorage()  else {
                throw Error.unexpectedValue(at: codingPath)
            }

            return UnkeyedContainer(codingPath: codingPath,
                                    storage: unkeyedStorage,
                                    userInfo: userInfo)
        }

        func singleValueContainer() throws -> SingleValueDecodingContainer {
            return SingleContainer(value: storage.singleStorage(),
                                   codingPath: codingPath,
                                   userInfo: userInfo)
        }

        enum Storage {
            case keyed([String: Any])
            case unkeyed([Any])
            case single(Any)

            func singleStorage() -> Any {
                switch self {
                case .keyed(let keyed):
                    return keyed
                case .unkeyed(let unkeyed):
                    return unkeyed
                case .single(let single):
                    return single
                }
            }

            func unkeyedStorage() -> [Any]? {
                switch self {
                case .keyed:
                    return nil
                case .unkeyed(let unkeyed):
                    return unkeyed
                case .single(let single):
                    return single as? [Any]
                }
            }

            func keyedStorage() -> [String: Any]? {
                switch self {
                case .keyed(let keyed):
                    return keyed
                case .unkeyed:
                    return nil
                case .single(let single):
                    return single as? [String: Any]
                }
            }
        }
    }

        enum AnyOptional {
        case none
        case some(Any)

        init?(_ any: Any) {
            guard Mirror(reflecting: any).displayStyle == .optional else {
                return nil
            }

            if case Optional<Any>.some(let wrapped) = any {
                self = .some(wrapped)
            } else {
                self = .none
            }
        }

        var isNone: Bool {
            switch self {
            case .none:
                return true
            case .some(_):
                return false
            }
        }
    }

    static func decode(_ type: URL.Type, from value: Any) -> URL? {
        if let url = value as? URL {
            return url
        } else if let string = value as? String {
            return URL(string: string)
        }
        return nil
    }

    static func decode<T>(_ type: T.Type, from value: Any?) -> T? where T: Decodable {
        guard let value = value else { return nil }

        if type == URL.self || type == NSURL.self {
            return decode(URL.self, from: value) as? T
        }

        if type == Data.self || type == NSData.self ||
           type == Date.self || type == NSDate.self ||
           type == Decimal.self || type == NSDecimalNumber.self {
            return value as? T
        }

        return nil
    }
}

extension DictionaryDecoder {

    struct KeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {

        let storage: [String: Any]
        let codingPath: [CodingKey]
        private let userInfo: [CodingUserInfoKey: Any]

        init(codingPath: [CodingKey], storage: [String: Any], userInfo: [CodingUserInfoKey: Any]) {
            self.codingPath = codingPath
            self.storage = storage
            self.userInfo = userInfo
        }

        var allKeys: [Key] {
            return storage.keys.compactMap {
                Key(stringValue: $0)
            }
        }

        func getValue<T>(for key: Key) throws -> T {
            guard let value = storage[key.stringValue] as? T else {
                let path = codingPath.appending(key: key)
                throw Error.unexpectedValue(at: path)
            }
            return value
        }

        private func getStorage(for key: Key) throws -> Decoder.Storage {
            guard let value = storage[key.stringValue] else {
                let path = codingPath.appending(key: key)
                throw Error.missingValue(at: path)
            }

            if let keyedValue = value as? [String: Any] {
                return .keyed(keyedValue)
            } else if let unkeyedValue = value as? [Any] {
                return .unkeyed(unkeyedValue)
            }
            return .single(value)
        }

        func contains(_ key: Key) -> Bool {
            return storage[key.stringValue] != nil
        }

        func decodeNil(forKey key: Key) throws -> Bool {
            let path = codingPath.appending(key: key)
            guard
                let value = storage[key.stringValue] else {
                throw Error.missingValue(at: path)
            }

            guard let optional = AnyOptional(value) else {
                throw Error.unexpectedValue(at: path)
            }

            return optional.isNone
        }

        func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
            return try getValue(for: key)
        }

        func decode(_ type: String.Type, forKey key: Key) throws -> String {
            return try getValue(for: key)
        }

        func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
            return try getValue(for: key)
        }

        func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
            return try getValue(for: key)
        }

        func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
            return try getValue(for: key)
        }

        func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
            return try getValue(for: key)
        }

        func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
            return try getValue(for: key)
        }

        func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
            return try getValue(for: key)
        }

        func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
            return try getValue(for: key)
        }

        func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
            return try getValue(for: key)
        }

        func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
            return try getValue(for: key)
        }

        func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
            return try getValue(for: key)
        }

        func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
            return try getValue(for: key)
        }

        func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
            return try getValue(for: key)
        }

        func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
            if let value = DictionaryDecoder.decode(T.self, from: self.storage[key.stringValue]) {
                return value
            }

            let path = codingPath.appending(key: key)
            let storage = try getStorage(for: key)
            let decoder = DictionaryDecoder.Decoder(codingPath: path, storage: storage, userInfo: userInfo)
            return try T.init(from: decoder)
        }

        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
            let path = codingPath.appending(key: key)
            let storage = try getValue(for: key) as [String: Any]
            let keyed = KeyedContainer<NestedKey>(codingPath: path,
                                                  storage: storage,
                                                  userInfo: userInfo)
            return KeyedDecodingContainer<NestedKey>(keyed)
        }

        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            let path = codingPath.appending(key: key)
            let storage = try getValue(for: key) as [Any]
            return UnkeyedContainer(codingPath: path,
                                    storage: storage,
                                    userInfo: userInfo)
        }

        func superDecoder() throws -> Swift.Decoder {
            return DictionaryDecoder.Decoder(codingPath: codingPath,
                                             storage: .keyed(storage),
                                             userInfo: userInfo)
        }

        func superDecoder(forKey key: Key) throws -> Swift.Decoder {
            let storage = try getStorage(for: key)
            return DictionaryDecoder.Decoder(codingPath: codingPath,
                                             storage: storage,
                                             userInfo: userInfo)
        }
    }

    struct UnkeyedContainer: UnkeyedDecodingContainer {

        let codingPath: [CodingKey]
        private let userInfo: [CodingUserInfoKey: Any]

        let storage: [Any]

        init(codingPath: [CodingKey], storage: [Any], userInfo: [CodingUserInfoKey: Any]) {
            self.codingPath = codingPath
            self.storage = storage
            self.userInfo = userInfo
        }

        var count: Int? {
            return storage.count
        }

        var isAtEnd: Bool {
            return currentIndex == storage.count
        }

        private(set) var currentIndex: Int = 0

        mutating func getValue<T>() throws -> T {
            guard
                isAtEnd == false,
                let value = storage[currentIndex] as? T else {
                    let path = codingPath.appending(index: currentIndex)
                    throw Error.unexpectedValue(at: path)
            }

            currentIndex += 1
            return value
        }

        private mutating func getStorage() throws -> Decoder.Storage {
            let value = try getValue() as Any

            if let keyedValue = value as? [String: Any] {
                return .keyed(keyedValue)
            } else if let unkeyedValue = value as? [Any] {
                return .unkeyed(unkeyedValue)
            }
            return .single(value)
        }

        mutating func decodeNil() throws -> Bool {
            let value = try getValue() as Any

            guard let optional = AnyOptional(value) else {
                let path = codingPath.appending(index: currentIndex)
                throw Error.unexpectedValue(at: path)
            }

            return optional.isNone
        }

        mutating func decode(_ type: Bool.Type) throws -> Bool {
            return try getValue()
        }

        mutating func decode(_ type: String.Type) throws -> String {
            return try getValue()
        }

        mutating func decode(_ type: Double.Type) throws -> Double {
            return try getValue()
        }

        mutating func decode(_ type: Float.Type) throws -> Float {
            return try getValue()
        }

        mutating func decode(_ type: Int.Type) throws -> Int {
            return try getValue()
        }

        mutating func decode(_ type: Int8.Type) throws -> Int8 {
            return try getValue()
        }

        mutating func decode(_ type: Int16.Type) throws -> Int16 {
            return try getValue()
        }

        mutating func decode(_ type: Int32.Type) throws -> Int32 {
            return try getValue()
        }

        mutating func decode(_ type: Int64.Type) throws -> Int64 {
            return try getValue()
        }

        mutating func decode(_ type: UInt.Type) throws -> UInt {
            return try getValue()
        }

        mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
            return try getValue()
        }

        mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
            return try getValue()
        }

        mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
            return try getValue()
        }

        mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
            return try getValue()
        }

        mutating func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
            if let value = DictionaryDecoder.decode(T.self, from: self.storage[currentIndex]) {
                currentIndex += 1
                return value
            }

            let path = codingPath.appending(index: currentIndex)
            let storage = try getStorage()
            let decoder = DictionaryDecoder.Decoder(codingPath: path,
                                                    storage: storage,
                                                    userInfo: userInfo)

            return try T.init(from: decoder)
        }

        mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
            let path = codingPath.appending(index: currentIndex)
            let storage = try getStorage()
            let decoder = DictionaryDecoder.Decoder(codingPath: path,
                                                    storage: storage,
                                                    userInfo: userInfo)
            return try decoder.container(keyedBy: type)
        }

        mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            let path = codingPath.appending(index: currentIndex)
            let storage = try getStorage()
            let decoder = DictionaryDecoder.Decoder(codingPath: path,
                                                    storage: storage,
                                                    userInfo: userInfo)
            return try decoder.unkeyedContainer()
        }

        mutating func superDecoder() throws -> Swift.Decoder {
            let path = codingPath.appending(index: currentIndex)
            let storage = try getStorage()
            return DictionaryDecoder.Decoder(codingPath: path,
                                             storage: storage,
                                             userInfo: userInfo)
        }
    }

    struct SingleContainer: SingleValueDecodingContainer {

        let codingPath: [CodingKey]
        private let userInfo: [CodingUserInfoKey: Any]

        private var value: Any

        init(value: Any, codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any]) {
            self.value = value
            self.codingPath = codingPath
            self.userInfo = userInfo
        }

        func decodeNil() -> Bool {
            let optional = AnyOptional(value)
            return optional?.isNone == true
        }

        func getValue<T>() throws -> T {
            guard let value = self.value as? T else {
                throw Error.unexpectedValue(at: codingPath)
            }
            return value
        }

        func decode(_ type: Bool.Type) throws -> Bool {
            return try getValue()
        }

        func decode(_ type: String.Type) throws -> String {
            return try getValue()
        }

        func decode(_ type: Double.Type) throws -> Double {
            return try getValue()
        }

        func decode(_ type: Float.Type) throws -> Float {
             return try getValue()
        }

        func decode(_ type: Int.Type) throws -> Int {
            return try getValue()
        }

        func decode(_ type: Int8.Type) throws -> Int8 {
            return try getValue()
        }

        func decode(_ type: Int16.Type) throws -> Int16 {
            return try getValue()
        }

        func decode(_ type: Int32.Type) throws -> Int32 {
            return try getValue()
        }

        func decode(_ type: Int64.Type) throws -> Int64 {
            return try getValue()
        }

        func decode(_ type: UInt.Type) throws -> UInt {
            return try getValue()
        }

        func decode(_ type: UInt8.Type) throws -> UInt8 {
            return try getValue()
        }

        func decode(_ type: UInt16.Type) throws -> UInt16 {
            return try getValue()
        }

        func decode(_ type: UInt32.Type) throws -> UInt32 {
             return try getValue()
        }

        func decode(_ type: UInt64.Type) throws -> UInt64 {
            return try getValue()
        }

        func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
            if let value = DictionaryDecoder.decode(T.self, from: self.value) {
                return value
            }

            let decoder = DictionaryDecoder.Decoder(codingPath: codingPath,
                                                    storage: .single(value),
                                                    userInfo: userInfo)
            return try T.init(from: decoder)
        }
    }
}
