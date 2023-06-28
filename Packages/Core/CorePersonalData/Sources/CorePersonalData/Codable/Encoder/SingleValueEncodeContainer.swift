import Foundation

struct SingleValueEncodeContainer: SingleValueEncodingContainer {

    let encoder: PersonalDataEncoderImpl
    let codingPath: [CodingKey]

    mutating func encodeNil() throws {
        encoder.value.value = nil
    }

    mutating func encode(_ value: Bool) throws {
        encoder.wrap(value)
    }

    mutating func encode(_ value: String) throws {
        encoder.wrap(value)
    }

    mutating func encode(_ value: Double) throws {
        encoder.wrap(value)
    }

    mutating func encode(_ value: Float) throws {
        encoder.wrap(value)
    }

    mutating func encode(_ value: Int) throws {
        encoder.wrap(value)
    }

    mutating func encode(_ value: Int8) throws {
        encoder.wrap(value)
    }

    mutating func encode(_ value: Int16) throws {
        encoder.wrap(value)
    }

    mutating func encode(_ value: Int32) throws {
        encoder.wrap(value)
    }

    mutating func encode(_ value: Int64) throws {
        encoder.wrap(value)
    }

    mutating func encode(_ value: UInt) throws {
        encoder.wrap(value)
    }

    mutating func encode(_ value: UInt8) throws {
        encoder.wrap(value)
    }

    mutating func encode(_ value: UInt16) throws {
        encoder.wrap(value)
    }

    mutating func encode(_ value: UInt32) throws {
        encoder.wrap(value)
    }

    mutating func encode(_ value: UInt64) throws {
        encoder.wrap(value)
    }

    mutating func encode(_ value: URL) throws {
        encoder.wrap(value)
    }

    mutating func encode(_ value: Date) throws {
        encoder.wrap(value)
    }

    mutating func encode<T>(_ value: T) throws where T: Encodable {
        try encoder.wrap(value)
    }
}
