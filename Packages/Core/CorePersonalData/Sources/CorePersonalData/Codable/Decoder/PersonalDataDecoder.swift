import Foundation
import DashTypes

public struct PersonalDataDecoder {
        struct Options {
        let userInfo: [CodingUserInfoKey: Any]
        let codeDecoder: CodeDecoder?
        let personalDataURLDecoder: PersonalDataURLDecoderProtocol?
        let linkedFetcher: LinkedFetcher?
        let metadata: RecordMetadata?
    }

    public var codeDecoder: CodeDecoder?
    public var personalDataURLDecoder: PersonalDataURLDecoderProtocol?

    public init(codeDecoder: CodeDecoder? = nil,
                personalDataURLDecoder: PersonalDataURLDecoderProtocol? = nil) {
        self.codeDecoder = codeDecoder
        self.personalDataURLDecoder = personalDataURLDecoder
    }

    public func decode<T>(_ type: T.Type, from value: PersonalDataValue, using linkedFetcher: LinkedFetcher? = nil) throws -> T where T: Decodable {
        let options = Options(userInfo: [:],
                              codeDecoder: codeDecoder,
                              personalDataURLDecoder: personalDataURLDecoder,
                              linkedFetcher: linkedFetcher,
                              metadata: nil)
        let decoder = PersonalDataDecoderImpl(value: value, options: options)
        return try T(from: decoder)
    }

    public func decode<T>(_ type: T.Type, from record: PersonalDataRecord, using linkedFetcher: LinkedFetcher? = nil) throws -> T where T: Decodable {
        let options = Options(userInfo: [:],
                              codeDecoder: codeDecoder,
                              personalDataURLDecoder: personalDataURLDecoder,
                              linkedFetcher: linkedFetcher,
                              metadata: record.metadata)
        let decoder = PersonalDataDecoderImpl(value: .collection(record.content), options: options)
        return try T(from: decoder)
    }
}

struct PersonalDataDecoderImpl: Decoder {
    let value: PersonalDataValue?
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey: Any] = [:]
    let options: PersonalDataDecoder.Options

    init(value: PersonalDataValue?, codingPath: [CodingKey] = [], options: PersonalDataDecoder.Options) {
        self.value = value
        self.codingPath = codingPath
        self.options = options
    }

    private func makeErrorContext(description: String) -> DecodingError.Context {
        DecodingError.Context(codingPath: self.codingPath, debugDescription: description)
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
        switch value {
            case let .collection(collection):
                let container = KeyedDecodeContainer<Key>(collection: collection,
                                                          codingPath: codingPath,
                                                          options: options)
                return KeyedDecodingContainer(container)
            case let .object(object):
                let container = KeyedDecodeContainer<Key>(collection: object.content,
                                                          codingPath: codingPath,
                                                          options: options)
                return KeyedDecodingContainer(container)

            case nil:
                throw DecodingError.valueNotFound(PersonalDataCollection.self,
                                                  makeErrorContext(description: "Expected to decode \(PersonalDataCollection.self) but found no value instead."))
            default:
                throw DecodingError.typeMismatch(PersonalDataCollection.self,
                                                 makeErrorContext(description: "Expected to decode \(PersonalDataCollection.self) but found \(value.debugCoderDescription) instead."))
        }

    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        let value = self.value ?? .list([]) 
        guard case let .list(list) = value else {
            throw DecodingError.typeMismatch(PersonalDataList.self,
                                             makeErrorContext(description: "Expected to decode \(PersonalDataList.self) but found \(value.debugCoderDescription) instead."))
        }

        return UnkeyedDecodeContainer(list: list,
                                      codingPath: codingPath,
                                      options: options)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return SingleValueDecodeContainer(decoder: self,
                                          codingPath: codingPath,
                                          options: options)
    }
}

extension PersonalDataDecoderImpl {
                func unwrapString() throws -> String {
        let value = self.value ?? .item("")
        guard case let .item(string) = value else {
            throw DecodingError.typeMismatch(String.self, makeErrorContext(description: "Expected to decode \(String.self) but found \(value.debugCoderDescription) instead."))
        }

        return string
    }

                func unwrapNumeric<T: Numeric & LosslessStringConvertible>(_ type: T.Type) throws -> T {
        let value = try unwrapString()

        guard !value.isEmpty, let value = T.init(value) else {
            return 0
        }

        return value
    }

                func unwrapBool() throws -> Bool {
        let value = try unwrapString()

        guard !value.isEmpty else {
            return false
        }

        let nsValue = value as NSString 
        return nsValue.boolValue
    }

    func unwrapDate() throws -> Date {
        let value = try unwrapString()

        guard !value.isEmpty else {
            throw DecodingError.valueNotFound(PersonalDataCollection.self,
                                              makeErrorContext(description: "Expected to decode \(Date.self) but found no value instead."))
        }

        guard let seconds = TimeInterval(value) else {
            throw DecodingError.dataCorrupted(makeErrorContext(description: "Invalid string \(value) for type \(Date.self)."))
        }

        return Date(timeIntervalSince1970: seconds)
    }

    func unwrapURL() throws -> URL {
        let value = try unwrapString()

        guard let url = URL(string: value) else {
            throw DecodingError.dataCorrupted(makeErrorContext(description: "Invalid string for type \(URL.self)."))
        }

        return url
    }

    func unwrapData() throws -> Data {
        let value = try unwrapString()

        guard !value.isEmpty, let data = Data(base64Encoded: value) else {
            throw DecodingError.dataCorrupted(makeErrorContext(description: "Invalid string for type \(Data.self)."))
        }

        return data
    }

    func unwrapPersonalDataURL() throws -> PersonalDataURL {
        let value = try unwrapString()

        guard let decoder = options.personalDataURLDecoder else {
            return PersonalDataURL(rawValue: value)
        }

        return try decoder.decodeURL(value)
    }

    func unwrapCodeNamePair(using type: CodeNamePair.Type) throws -> CodeNamePair {
        let value = try unwrapString()

        guard let decoder = options.codeDecoder,
              let name = try decoder.decodeCode(value, for: type.codeFormat) else {
            return type.init(code: value, name: "")
        }

        return type.init(code: value, name: name)
    }

    func unwrapLinked<T: PersonalDataCodable>(using type: T.Type) throws -> Linked<T> {
        let rawId = try unwrapString()
        guard !rawId.isEmpty else {
            return Linked(nil)
        }

        let identifier = Identifier(rawId)
        if let identity = try options.linkedFetcher?.fetch(with: identifier, type: type) {
            return Linked(identity)
        } else {
            return Linked(identifier: identifier)
        }
    }

            func unwrap<T: Decodable>(as type: T.Type) throws -> T {
        if type == Date.self {
            return try self.unwrapDate() as! T
        } else if type == URL.self {
            return try self.unwrapURL() as! T
        } else if type == Data.self {
            return try self.unwrapData() as! T
        } else if type == PersonalDataURL.self {
            return try self.unwrapPersonalDataURL() as! T
        } else if let codeType = type as? CodeNamePair.Type {
            return try self.unwrapCodeNamePair(using: codeType) as! T
        } else if type == RecordMetadata.self, let metadata = options.metadata {
           return metadata as! T
        } else if let nestedType = type as? NestedObject.Type {
            guard case let .object(object) = value, object.type == nestedType.contentType else {
                throw DecodingError.typeMismatch(PersonalDataObject.self,
                                                 makeErrorContext(description: "Expected to decode \(PersonalDataObject.self) with content type \(nestedType.contentType) but found \(value.debugCoderDescription) instead."))
            }
            return try T(from: self)
        } else if type == Linked<Identity>.self {
            return try self.unwrapLinked(using: Identity.self) as! T
        } else if type == PersonalDataCollection.self {
            guard case let .collection(collection) = value else {
                throw DecodingError.typeMismatch(PersonalDataObject.self,
                                                 makeErrorContext(description: "Expected to decode \(PersonalDataCollection.self) but found \(value.debugCoderDescription) instead."))
            }
            return collection as! T
        } else {
            return try T(from: self)
        }
    }
        func unwrapOptional<T: Decodable>(as type: T.Type) throws -> T? {
        if type is CodeNamePair.Type {
            return try? self.unwrap(as: type) 
        } else {
            return try self.unwrap(as: type)
        }
    }
}

private extension PersonalDataValue {
    var debugCoderDescription: String {
        switch self {
            case .list:
                return String(describing: PersonalDataList.self)
            case .collection:
                return String(describing: PersonalDataCollection.self)
            case let .object(object):
                return String(describing: PersonalDataObject.self) + "." + object.$type
            case .item:
                return String(describing: String.self)
        }
    }
}

private extension Optional where  Wrapped == PersonalDataValue {
    var debugCoderDescription: String {
        switch self {
            case let .some(value):
                return value.debugCoderDescription
            case .none:
                return "Nil"
        }
    }
}
