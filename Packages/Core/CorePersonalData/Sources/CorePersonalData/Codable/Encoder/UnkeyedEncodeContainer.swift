import Foundation

struct UnkeyedEncodeContainer: UnkeyedEncodingContainer {
    let list: RefList
    let codingPath: [CodingKey]

    var count: Int {
        return list.count
    }

        mutating func encodeNil() throws {

    }

    mutating func encode(_ value: Bool) throws {
        currentEncoder().wrap(value)
    }

    mutating func encode(_ value: String) throws {
        currentEncoder().wrap(value)
    }

    mutating func encode(_ value: Double) throws {
        currentEncoder().wrap(value)
    }

    mutating func encode(_ value: Float) throws {
        currentEncoder().wrap(value)
    }

    mutating func encode(_ value: Int) throws {
        currentEncoder().wrap(value)
    }

    mutating func encode(_ value: Int8) throws {
        currentEncoder().wrap(value)
    }

    mutating func encode(_ value: Int16) throws {
        currentEncoder().wrap(value)
    }

    mutating func encode(_ value: Int32) throws {
        currentEncoder().wrap(value)
    }

    mutating func encode(_ value: Int64) throws {
        currentEncoder().wrap(value)
    }

    mutating func encode(_ value: UInt) throws {
        currentEncoder().wrap(value)
    }

    mutating func encode(_ value: UInt8) throws {
        currentEncoder().wrap(value)
    }

    mutating func encode(_ value: UInt16) throws {
        currentEncoder().wrap(value)
    }

    mutating func encode(_ value: UInt32) throws {
        currentEncoder().wrap(value)
    }

    mutating func encode(_ value: UInt64) throws {
        currentEncoder().wrap(value)
    }

    mutating func encode<T>(_ value: T) throws where T: Encodable {
        try currentEncoder().wrap(value)
    }

        mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        currentEncoder().container(keyedBy: keyType)
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        currentEncoder().unkeyedContainer()
    }

        mutating func superEncoder() -> Encoder {
        return currentEncoder()
    }

    func currentCodingPath() -> [CodingKey] {
        var newPath = self.codingPath
        newPath.append(ListIndexKey(index: count))
        return newPath
    }

    private func currentEncoder() -> PersonalDataEncoderImpl {
        let value = RefValue()
        list.add(value)
        return PersonalDataEncoderImpl(value: value, codingPath: currentCodingPath())
    }
}
