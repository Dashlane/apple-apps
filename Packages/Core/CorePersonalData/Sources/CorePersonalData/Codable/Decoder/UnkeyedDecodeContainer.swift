import Foundation

struct UnkeyedDecodeContainer: UnkeyedDecodingContainer {
    let codingPath: [CodingKey]
    let list: PersonalDataList
    let options: PersonalDataDecoder.Options

    var count: Int? {
        return list.count
    }

    var isAtEnd: Bool {
        return list.count <= currentIndex
    }

    var currentIndex: Int = 0

    init(list: PersonalDataList, codingPath: [CodingKey], options: PersonalDataDecoder.Options) {
        self.list = list
        self.codingPath = codingPath
        self.options = options
    }

        func current() throws -> PersonalDataValue {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Unkeyed container is at end."))
        }
        return list[currentIndex]
    }

    func currentCodingPath() -> [CodingKey] {
        var newPath = self.codingPath
        newPath.append(ListIndexKey(index: currentIndex))
        return newPath
    }

        mutating func decodeNil() throws -> Bool {
        let value = try current().item == nil
        currentIndex += 1
        return value
    }

    mutating func decode(_ type: Bool.Type) throws -> Bool {
        let value = try currentDecoder().unwrapBool()
        currentIndex += 1
        return value
    }

    mutating func decode(_ type: String.Type) throws -> String {
        let value = try currentDecoder().unwrapString()
        currentIndex += 1
        return value
    }

    mutating func decode(_ type: Double.Type) throws -> Double {
        let value = try currentDecoder().unwrapNumeric(Double.self)
        currentIndex += 1
        return value
    }

    mutating func decode(_ type: Float.Type) throws -> Float {
        let value = try currentDecoder().unwrapNumeric(Float.self)
        currentIndex += 1
        return value
    }

    mutating func decode(_ type: Int.Type) throws -> Int {
        let value = try currentDecoder().unwrapNumeric(Int.self)
        currentIndex += 1
        return value
    }

    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        let value = try currentDecoder().unwrapNumeric(Int8.self)
        currentIndex += 1
        return value
    }

    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        let value = try currentDecoder().unwrapNumeric(Int16.self)
        currentIndex += 1
        return value
    }

    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        let value = try currentDecoder().unwrapNumeric(Int32.self)
        currentIndex += 1
        return value
    }

    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        let value = try currentDecoder().unwrapNumeric(Int64.self)
        currentIndex += 1
        return value
    }

    mutating func decode(_ type: UInt.Type) throws -> UInt {
        let value = try currentDecoder().unwrapNumeric(UInt.self)
        currentIndex += 1
        return value
    }

    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        let value = try currentDecoder().unwrapNumeric(UInt8.self)
        currentIndex += 1
        return value
    }

    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        let value = try currentDecoder().unwrapNumeric(UInt16.self)
        currentIndex += 1
        return value
    }

    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        let value = try currentDecoder().unwrapNumeric(UInt32.self)
        currentIndex += 1
        return value
    }

    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        let value = try currentDecoder().unwrapNumeric(UInt64.self)
        currentIndex += 1
        return value
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        let value = try currentDecoder().unwrap(as: type)
        currentIndex += 1
        return value
    }

        mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        let container = try currentDecoder().container(keyedBy: type)
        currentIndex += 1
        return container
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        let container = try currentDecoder().unkeyedContainer()
        self.currentIndex += 1
        return container
    }

        private func currentDecoder() throws -> PersonalDataDecoderImpl {
        return try PersonalDataDecoderImpl(value: current(), codingPath: currentCodingPath(), options: options)
    }

    mutating func superDecoder() throws -> Decoder {
        let decoder = try currentDecoder()
        currentIndex += 1
        return decoder
    }
}

struct ListIndexKey: CodingKey {
    let index: Int
    var stringValue: String {
        "\(index)"
    }
    var intValue: Int? {
       index
    }
    init?(stringValue: String) {
        guard let index = Int(stringValue) else {
            return nil
        }
        self.index = index
    }

    init?(intValue: Int) {
        self.index = intValue
    }

    init(index: Int) {
        self.index = index
    }
}
