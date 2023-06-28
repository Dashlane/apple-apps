import Foundation

struct KeyedDecodeContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    let collection: PersonalDataCollection
    let codingPath: [CodingKey]
    let options: PersonalDataDecoder.Options
    let allKeys: [Key]

    init(collection: PersonalDataCollection,
         codingPath: [CodingKey],
         options: PersonalDataDecoder.Options) {
        self.collection = collection
        self.codingPath = codingPath
        self.options = options
        self.allKeys = collection.keys.compactMap { Key(stringValue: $0) }
    }

        @inline(__always) private func value(for key: Key) throws -> PersonalDataValue {
        guard let value = collection[key] else {
            throw DecodingError.keyNotFound(key, .init(
                codingPath: self.codingPath,
                debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."
            ))
        }

        return value
    }

    @inline(__always) private func codingPath(for key: Key) -> [CodingKey] {
        var newPath = self.codingPath
        newPath.append(key)
        return newPath
    }

    func contains(_ key: Key) -> Bool {
        collection[key] != nil && collection[key] != .item("")
    }

        func decodeNil(forKey key: Key) throws -> Bool {
        collection[key] == nil
    }

    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        try decoder(for: key).unwrapBool()
    }

    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        try decoder(for: key).unwrapNumeric(Double.self)
    }

    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        try decoder(for: key).unwrapNumeric(Float.self)
    }

    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        try decoder(for: key).unwrapNumeric(Int.self)
    }

    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        try decoder(for: key).unwrapNumeric(Int8.self)
    }

    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        try decoder(for: key).unwrapNumeric(Int16.self)
    }

    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        try decoder(for: key).unwrapNumeric(Int32.self)
    }

    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        try decoder(for: key).unwrapNumeric(Int64.self)
    }

    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        try decoder(for: key).unwrapNumeric(UInt.self)
    }

    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        try decoder(for: key).unwrapNumeric(UInt8.self)
    }

    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        try decoder(for: key).unwrapNumeric(UInt16.self)
    }

    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        try decoder(for: key).unwrapNumeric(UInt32.self)
    }

    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        try decoder(for: key).unwrapNumeric(UInt64.self)
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
        try decoder(for: key).unwrap(as: type)
    }

    func decodeIfPresent<T>(_ type: T.Type, forKey key: Key) throws -> T? where T: Decodable {
        guard contains(key) else {
            return nil
        }
        return try? decoder(for: key).unwrap(as: type)
    }

        func decode(_ type: String.Type, forKey key: Key) throws -> String {
        try decoder(for: key).unwrapString()
    }

        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        return try superDecoder(forKey: key).container(keyedBy: type)
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        return try superDecoder(forKey: key).unkeyedContainer()
    }

        func superDecoder() throws -> Decoder {
        let decoder = PersonalDataDecoderImpl(value: .collection(collection),
                                              codingPath: codingPath,
                                              options: options)
        return decoder
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        return decoder(for: key)
    }

    private func decoder(for key: Key) -> PersonalDataDecoderImpl {
        let decoder = PersonalDataDecoderImpl(value: collection[key],
                                              codingPath: codingPath(for: key),
                                              options: options)
        return decoder
    }
}

extension Dictionary where Key == String {
    subscript(_ key: CodingKey) -> Value? {
        return self[key.stringValue]
    }
}
