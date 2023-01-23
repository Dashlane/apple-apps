import Foundation

public final class DictionaryEncoder {
    public enum KeyEncodingStrategyKey {
                case useDefaultKeys
        
                case uppercaseFirstCharacter
    }
    
    static let dateEncodingStrategyKey = CodingUserInfoKey(rawValue: "dateEncodingStrategyKey")!

    public var userInfo: [CodingUserInfoKey: Any]
    public let keyEncodingStrategyKey: KeyEncodingStrategyKey

    public init (dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil, keyEncodingStrategyKey: KeyEncodingStrategyKey = .useDefaultKeys) {
        if let strategy = dateEncodingStrategy {
            self.userInfo = [Self.dateEncodingStrategyKey: strategy]
        } else {
            self.userInfo = [:]
        }
        self.keyEncodingStrategyKey = keyEncodingStrategyKey
    }

    public func encode<T>(_ value: T) throws -> [String: Any] where T: Encodable {
        guard let dictionary = try Encoder(userInfo: userInfo, keyEncodingStrategyKey: keyEncodingStrategyKey).encodeToAny(value) as? [String: Any] else {
            throw Error.unsupported
        }

        return dictionary
    }

    public func encodeToArray<T>(_ value: T) throws -> [Any] where T: Encodable {
        guard let array = try Encoder(userInfo: userInfo, keyEncodingStrategyKey: keyEncodingStrategyKey).encodeToAny(value) as? [Any] else {
            throw Error.unsupported
        }

        return array
    }
}

private extension DictionaryEncoder {

    enum Storage {
        case value(Any)
        case container(EncoderContainer)

        func toAny() throws -> Any {
            switch self {
            case .value(let value):
                return value
            case .container(let container):
                return try container.toAny()
            }
        }
    }

    enum Error: Swift.Error {
        case unsupported
        case incomplete(at: [CodingKey])
    }

    final class Encoder: Swift.Encoder, EncoderContainer {
        let codingPath: [CodingKey]
        let userInfo: [CodingUserInfoKey: Any]
        let keyEncodingStrategyKey: KeyEncodingStrategyKey
        
        init(codingPath: [CodingKey] = [], userInfo: [CodingUserInfoKey: Any], keyEncodingStrategyKey: KeyEncodingStrategyKey) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.keyEncodingStrategyKey = keyEncodingStrategyKey
        }

        private(set) var container: EncoderContainer? {
            didSet {
                precondition(oldValue == nil)
            }
        }

        func toAny() throws -> Any {
            guard let container = self.container else {
                throw Error.incomplete(at: codingPath)
            }

            return try container.toAny()
        }

        func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
            let keyed = KeyedContainer<Key>(codingPath: codingPath, userInfo: userInfo, keyEncodingStrategyKey: keyEncodingStrategyKey)
            container = keyed
            return KeyedEncodingContainer(keyed)
        }

        func unkeyedContainer() -> UnkeyedEncodingContainer {
            let unkeyed = UnkeyedContainer(codingPath: codingPath, userInfo: userInfo, keyEncodingStrategyKey: keyEncodingStrategyKey)
            container = unkeyed
            return unkeyed
        }

        func singleValueContainer() -> SingleValueEncodingContainer {
            let single = SingleContainer(codingPath: codingPath, userInfo: userInfo, keyEncodingStrategyKey: keyEncodingStrategyKey)
            container = single
            return single
        }

        func encodeToAny<T>(_ value: T) throws -> Any where T: Encodable {
            try value.encode(to: self)
            return try toAny()
        }
    }

    static func isSupportedType<T>(_ type: T.Type) -> Bool where T: Encodable {
        return
            T.self == Data.self || T.self == NSData.self ||
            T.self == Decimal.self || T.self == NSDecimalNumber.self ||
            T.self == URL.self || T.self == NSURL.self
    }
}

private protocol EncoderContainer {
    func toAny() throws -> Any
}

extension DictionaryEncoder {

    final class KeyedContainer<K: CodingKey>: KeyedEncodingContainerProtocol, EncoderContainer {
        typealias Key = K

        let codingPath: [CodingKey]
        private let userInfo: [CodingUserInfoKey: Any]
        let keyEncodingStrategyKey: KeyEncodingStrategyKey
        
        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any], keyEncodingStrategyKey: KeyEncodingStrategyKey) {
            self.codingPath = codingPath
            self.storage = [:]
            self.userInfo = userInfo
            self.keyEncodingStrategyKey = keyEncodingStrategyKey
        }

        private var storage: [String: Storage]

        private func makeStorageKey(key: Key) -> String {
            let key = key.stringValue
            
            switch keyEncodingStrategyKey {
                case .useDefaultKeys:
                    return key
                case .uppercaseFirstCharacter:
                    return key.capitalizingFirstLetter()
            }
        }
        
        func toAny() throws -> Any {
            return try storage.mapValues { try $0.toAny() }
        }

        func encodeNil(forKey key: Key) throws {
            storage[makeStorageKey(key: key)] = .value(Optional<Any>.none as Any)
        }

        func encode(_ value: Bool, forKey key: Key) throws {
            storage[makeStorageKey(key: key)] = .value(value)
        }

        func encode(_ value: Int, forKey key: Key) throws {
            storage[makeStorageKey(key: key)] = .value(value)
        }

        func encode(_ value: Int8, forKey key: Key) throws {
            storage[makeStorageKey(key: key)] = .value(value)
        }

        func encode(_ value: Int16, forKey key: Key) throws {
            storage[makeStorageKey(key: key)] = .value(value)
        }

        func encode(_ value: Int32, forKey key: Key) throws {
            storage[makeStorageKey(key: key)] = .value(value)
        }

        func encode(_ value: Int64, forKey key: Key) throws {
            storage[makeStorageKey(key: key)] = .value(value)
        }

        func encode(_ value: UInt, forKey key: Key) throws {
            storage[makeStorageKey(key: key)] = .value(value)
        }

        func encode(_ value: UInt8, forKey key: Key) throws {
            storage[makeStorageKey(key: key)] = .value(value)
        }

        func encode(_ value: UInt16, forKey key: Key) throws {
            storage[makeStorageKey(key: key)] = .value(value)
        }

        func encode(_ value: UInt32, forKey key: Key) throws {
            storage[makeStorageKey(key: key)] = .value(value)
        }

        func encode(_ value: UInt64, forKey key: Key) throws {
            storage[makeStorageKey(key: key)] = .value(value)
        }

        func encode(_ value: String, forKey key: Key) throws {
            storage[makeStorageKey(key: key)] = .value(value)
        }

        func encode(_ value: Float, forKey key: Key) throws {
            storage[makeStorageKey(key: key)] = .value(value)
        }

        func encode(_ value: Double, forKey key: Key) throws {
            storage[makeStorageKey(key: key)] = .value(value)
        }
        
        func encode(_ value: Date, forKey key: Key) throws {
            guard let strategy = userInfo[dateEncodingStrategyKey] as? JSONEncoder.DateEncodingStrategy else {
                storage[makeStorageKey(key: key)] = .value(value)
                return
            }
            switch strategy {
            case .secondsSince1970:
                storage[makeStorageKey(key: key)] = .value(value.timeIntervalSince1970)
            default:
                return storage[makeStorageKey(key: key)] = .value(value)
            }
        }

        func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
            guard DictionaryEncoder.isSupportedType(T.self) == false else {
                storage[makeStorageKey(key: key)] = .value(value)
                return
            }
            
            if let date = value as? Date {
                try encode(date, forKey: key)
                return
            }

            let path = codingPath.appending(key: key)
            let result = try Encoder(codingPath: path, userInfo: userInfo, keyEncodingStrategyKey: keyEncodingStrategyKey).encodeToAny(value)
            storage[makeStorageKey(key: key)] = .value(result)
        }

        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
            let path = codingPath.appending(key: key)
            let keyed = KeyedContainer<NestedKey>(codingPath: path, userInfo: userInfo, keyEncodingStrategyKey: keyEncodingStrategyKey)
            storage[makeStorageKey(key: key)] = .container(keyed)
            return KeyedEncodingContainer(keyed)
        }

        func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
            let path = codingPath.appending(key: key)
            let unkeyed = UnkeyedContainer(codingPath: path, userInfo: userInfo, keyEncodingStrategyKey: keyEncodingStrategyKey)
            storage[makeStorageKey(key: key)] = .container(unkeyed)
            return unkeyed
        }

        func superEncoder() -> Swift.Encoder {
            return superEncoder(forKey: Key(stringValue: "super")!)
        }

        func superEncoder(forKey key: Key) -> Swift.Encoder {
            let path = codingPath.appending(key: key)
            let encoder = Encoder(codingPath: path, userInfo: userInfo, keyEncodingStrategyKey: keyEncodingStrategyKey)
            storage[makeStorageKey(key: key)] = .container(encoder)
            return encoder
        }
    }

    final class UnkeyedContainer: Swift.UnkeyedEncodingContainer, EncoderContainer {

        let codingPath: [CodingKey]
        private let userInfo: [CodingUserInfoKey: Any]
        let keyEncodingStrategyKey: KeyEncodingStrategyKey
        
        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any], keyEncodingStrategyKey: KeyEncodingStrategyKey) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.keyEncodingStrategyKey = keyEncodingStrategyKey
        }

        private var storage: [Storage] = []

        func toAny() throws -> Any {
            return try storage.map { try $0.toAny() }
        }

        public var count: Int {
            return storage.count
        }

        func encodeNil() throws {
            storage.append(.value(Optional<Any>.none as Any))
        }

        func encode(_ value: Bool) throws {
            storage.append(.value(value))
        }

        func encode(_ value: Int) throws {
            storage.append(.value(value))
        }

        func encode(_ value: Int8) throws {
            storage.append(.value(value))
        }

        func encode(_ value: Int16) throws {
            storage.append(.value(value))
        }

        func encode(_ value: Int32) throws {
            storage.append(.value(value))
        }

        func encode(_ value: Int64) throws {
            storage.append(.value(value))
        }

        func encode(_ value: UInt) throws {
            storage.append(.value(value))
        }

        func encode(_ value: UInt8) throws {
            storage.append(.value(value))
        }

        func encode(_ value: UInt16) throws {
            storage.append(.value(value))
        }

        func encode(_ value: UInt32) throws {
            storage.append(.value(value))
        }

        func encode(_ value: UInt64) throws {
            storage.append(.value(value))
        }

        func encode(_ value: String) throws {
            storage.append(.value(value))
        }

        func encode(_ value: Float) throws {
            storage.append(.value(value))
        }

        func encode(_ value: Double) throws {
            storage.append(.value(value))
        }

        func encode<T: Encodable>(_ value: T) throws {
            guard DictionaryEncoder.isSupportedType(T.self) == false else {
                storage.append(.value(value))
                return
            }

            let path = codingPath.appending(index: count)
            let result = try Encoder(codingPath: path, userInfo: userInfo, keyEncodingStrategyKey: keyEncodingStrategyKey).encodeToAny(value)
            storage.append(.value(result))
        }

        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
            let path = codingPath.appending(index: count)
            let keyed = KeyedContainer<NestedKey>(codingPath: path, userInfo: userInfo, keyEncodingStrategyKey: keyEncodingStrategyKey)
            storage.append(.container(keyed))
            return KeyedEncodingContainer(keyed)
        }

        func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
            let path = codingPath.appending(index: count)
            let unkeyed = UnkeyedContainer(codingPath: path, userInfo: userInfo, keyEncodingStrategyKey: keyEncodingStrategyKey)
            storage.append(.container(unkeyed))
            return unkeyed
        }

        func superEncoder() -> Swift.Encoder {
            let path = codingPath.appending(index: count)
            let encoder = Encoder(codingPath: path, userInfo: userInfo, keyEncodingStrategyKey: keyEncodingStrategyKey)
            storage.append(.container(encoder))
            return encoder
        }
    }

    final class SingleContainer: SingleValueEncodingContainer, EncoderContainer {

        let codingPath: [CodingKey]
        private let userInfo: [CodingUserInfoKey: Any]
        let keyEncodingStrategyKey: KeyEncodingStrategyKey
        
        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any], keyEncodingStrategyKey: KeyEncodingStrategyKey) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.keyEncodingStrategyKey = keyEncodingStrategyKey
        }

        var storage: Any?

        func toAny() throws -> Any {
            guard let value = storage else {
                throw Error.incomplete(at: codingPath)
            }
            return value
        }

        func encodeNil() throws {
            storage = .some(Optional<Any>.none as Any)
        }

        func encode(_ value: Bool) throws {
            storage = value
        }

        func encode(_ value: String) throws {
            storage = value
        }

        func encode(_ value: Double) throws {
            storage = value
        }

        func encode(_ value: Float) throws {
            storage = value
        }

        func encode(_ value: Int) throws {
            storage = value
        }

        func encode(_ value: Int8) throws {
            storage = value
        }

        func encode(_ value: Int16) throws {
            storage = value
        }

        func encode(_ value: Int32) throws {
            storage = value
        }

        func encode(_ value: Int64) throws {
            storage = value
        }

        func encode(_ value: UInt) throws {
            storage = value
        }

        func encode(_ value: UInt8) throws {
            storage = value
        }

        func encode(_ value: UInt16) throws {
            storage = value
        }

        func encode(_ value: UInt32) throws {
            storage = value
        }

        func encode(_ value: UInt64) throws {
            storage = value
        }

        func encode<T>(_ value: T) throws where T: Encodable {
            guard DictionaryEncoder.isSupportedType(T.self) == false else {
                storage = value
                return
            }

            let encoder = Encoder(codingPath: codingPath, userInfo: userInfo, keyEncodingStrategyKey: keyEncodingStrategyKey)
            storage = try encoder.encodeToAny(value)
        }
    }
}

extension Array where Element == CodingKey {

    func appending(key codingKey: CodingKey) -> [CodingKey] {
        var path = self
        path.append(codingKey)
        return path
    }

    func appending(index: Int) -> [CodingKey] {
        var path = self
        path.append(IndexKey(intValue: index))
        return path
    }

    struct IndexKey: CodingKey {
        var intValue: Int? {
            return index
        }

        var stringValue: String {
            return "Index \(index)"
        }

        var index: Int

        init(intValue index: Int) {
            self.index = index
        }

        init?(stringValue: String) {
            return nil
        }
    }
}
