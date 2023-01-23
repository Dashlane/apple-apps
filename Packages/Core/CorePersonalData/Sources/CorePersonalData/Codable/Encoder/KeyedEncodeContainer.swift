import Foundation

internal struct KeyedEncodeContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    let encoder: PersonalDataEncoderImpl
    let collection: RefCollection
    let codingPath: [CodingKey]
    
    init(encoder: PersonalDataEncoderImpl,
         collection: RefCollection,
         codingPath: [CodingKey]) {
        self.encoder = encoder
        self.collection = collection
        self.codingPath = codingPath
    }
    
    @inline(__always) private func codingPath(for key: Key) -> [CodingKey] {
        var newPath = self.codingPath
        newPath.append(key)
        return newPath
    }
    
        mutating func encodeNil(forKey key: Key) throws {
        collection[key] = nil
    }
    
    mutating func encode(_ value: Bool, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }
    
    mutating func encode(_ value: String, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }
    
    mutating func encode(_ value: Double, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }
    
    mutating func encode(_ value: Float, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }
    
    mutating func encode(_ value: Int, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }
    
    mutating func encode(_ value: Int8, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }
    
    mutating func encode(_ value: Int16, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }
    
    mutating func encode(_ value: Int32, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }
    
    mutating func encode(_ value: Int64, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }
    
    mutating func encode(_ value: UInt, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }
    
    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }
    
    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }
    
    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }
    
    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }
    
    mutating func encode(_ value: URL, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }
    
    mutating func encode(_ value: Date, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }

    mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        try encoder(for: key).wrap(value)
    }
    
        mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        encoder(for: key).container(keyedBy: keyType)
    }
    
    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        encoder(for: key).unkeyedContainer()
    }
    
        mutating func superEncoder() -> Encoder {
        encoder
    }
    
    mutating func superEncoder(forKey key: Key) -> Encoder {
        encoder(for: key)
    }
    
    mutating func encoder(for key: Key) -> PersonalDataEncoderImpl {
       let value = RefValue()
       collection[key] = value
       return PersonalDataEncoderImpl(value: value, codingPath: codingPath(for: key))
    }
    
    mutating func encodeIfPresent<T>(_ value: T?, forKey key: Key) throws where T : Encodable {
        try encoder(for: key).wrap(value)
    }

    public mutating func encodeIfPresent(_ value: Bool?, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }

    public mutating func encodeIfPresent(_ value: String?, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }

    public mutating func encodeIfPresent(_ value: Double?, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }

    public mutating func encodeIfPresent(_ value: Float?, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }

    public mutating func encodeIfPresent(_ value: Int?, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }

    public mutating func encodeIfPresent(_ value: Int8?, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }

    public mutating func encodeIfPresent(_ value: Int16?, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }

    public mutating func encodeIfPresent(_ value: Int32?, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }

    public mutating func encodeIfPresent(_ value: Int64?, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }

    public mutating func encodeIfPresent(_ value: UInt?, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }

    public mutating func encodeIfPresent(_ value: UInt8?, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }

    public mutating func encodeIfPresent(_ value: UInt16?, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }

    public mutating func encodeIfPresent(_ value: UInt32?, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }

    public mutating func encodeIfPresent(_ value: UInt64?, forKey key: Key) throws {
        encoder(for: key).wrap(value)
    }
}
