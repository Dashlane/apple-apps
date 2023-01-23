import Foundation
import SwiftTreats

public struct PersonalDataEncoder {

    public init() {}
    
                public func encode<T: Encodable>(_ value: T, in collection: PersonalDataCollection = [:]) throws -> PersonalDataCollection {
        let ref = RefValue(.collection(RefCollection(collection)))
        let encoder = PersonalDataEncoderImpl(value: ref)
        try value.encode(to: encoder)
        guard let value = ref.personalDataValue()?.collection else {
            throw DecodingError.valueNotFound(T.self, .init(codingPath: [], debugDescription: "Cannot decode \(T.self)"))
        }
        return value
    }
}

struct PersonalDataEncoderImpl: Encoder {
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey : Any] = [:]
    let value: RefValue

    init(value: RefValue, codingPath: [CodingKey] = []) {
        self.value = value
        self.codingPath = codingPath
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let collection = value.collection ?? RefCollection()
        value.value = .collection(collection)
        let container = KeyedEncodeContainer<Key>(encoder: self, collection: collection, codingPath: self.codingPath)
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        let list = RefList()
        value.value = .list(list)
        return UnkeyedEncodeContainer(list: list, codingPath: codingPath)
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        return SingleValueEncodeContainer(encoder: self, codingPath: codingPath)
    }
}

extension PersonalDataEncoderImpl {
                    func wrap(_ string: String) -> Void {
                guard !(value.value == nil && string.isEmpty) else {
            return
        }
        
        value.value = .item(string)
    }
    
    func wrap(_ bool: Bool) -> Void {
        wrap(String(bool))
    }

    func wrap<T: Numeric & LosslessStringConvertible>(_ number: T) -> Void {
        wrap(String(number))
    }
    
    func wrap(_ date: Date) -> Void {
        wrap(String(Int(date.timeIntervalSince1970)))
    }
    
    func wrap(_ url: URL) -> Void {
        wrap(url.absoluteString)
    }
    
    func wrap(_ data: Data) -> Void {
        wrap(data.base64EncodedString())
    }
    
    func wrap(_ url: PersonalDataURL) -> Void {
        wrap(url.rawValue)
    }
    
    func wrap<T: PersonalDataCodable>(_ identity: Linked<T>) throws -> Void {
        try wrap(identity.identifier)
    }
    
    func wrap<T: Encodable>(_ object: T, for type: XMLDataType) throws -> Void {
        let refObject = RefObject(type: type)
        value.value = .object(refObject)
        let refValue = RefValue(.collection(refObject.content))
        let encoder = PersonalDataEncoderImpl(value: refValue, codingPath: codingPath)
        try object.encode(to: encoder)
    }
    
    func wrap<T: Encodable>(_ object: T) throws -> Void {
        if let date = object as? Date {
            wrap(date)
        } else if let url = object as? URL {
            wrap(url)
        } else if let data = object as? Data {
            wrap(data)
        } else if let url = object as? PersonalDataURL {
            wrap(url)
        } else if let codePair = object as? CodeNamePair {
            wrap(codePair.code)
        } else if object is RecordMetadata {
                    } else if let nestedObject = object as? NestedObject {
            try wrap(object, for: type(of: nestedObject).contentType)
        } else if let link = object as? Linked<Identity> {
            try wrap(link)
        } else if let link = object as? Linked<SecureNoteCategory> {
            try wrap(link)
        } else if let link = object as? Linked<CredentialCategory> {
            try wrap(link)
        } else if let collection = object as? PersonalDataCollection {
            value.value = .collection(RefCollection(collection))
        } else {
            try object.encode(to: self)
        }
    }
}

extension PersonalDataEncoderImpl {
    func wrap(_ string: String?) -> Void {
        value.value = string.map { .item($0) }
    }
    
    func wrap(_ bool: Bool?) -> Void {
        wrap(bool.map(String.init))
    }
    
    func wrap<T: Numeric & LosslessStringConvertible>(_ number: T?) -> Void {
        wrap(number.map(String.init))
    }
    
    func wrap(_ date: Date?) -> Void {
        wrap(date.map(\.timeIntervalSince1970))
    }
    
    func wrap(_ url: URL?) -> Void {
        wrap(url.map(\.absoluteString))
    }
    
    func wrap<T: Encodable>(_ object: T?) throws -> Void {
        if let object = object {
            try wrap(object)
        } else {
            value.value = nil
        }
    }
}

class RefValue {
    indirect enum EncodedValue {
        case item(String)
        case collection(RefCollection)
        case list(RefList)
        case object(RefObject)
    }
    
    var value: EncodedValue?
    
    init(_ value: EncodedValue? = nil) {
        self.value = value
    }
    
    var collection: RefCollection? {
        switch value {
            case let .collection(collection):
                return collection
            default:
               return nil
        }
    }
}

class RefCollection {
    var value: [String: RefValue]

    init(_ collection: [String: RefValue] = [:]) {
        self.value = collection
    }
    
    subscript(key: CodingKey) -> RefValue? {
        get {
            value[key]
        }
        set {
            if let newValue = newValue {
                value[key.stringValue] = newValue
            } else {
                value.removeValue(forKey: key.stringValue)
            }
        }
    }
}

class RefList {
    var value: [RefValue]
    var count: Int {
        value.count
    }
    
    init(_ list:  [RefValue] = []) {
        self.value = list
    }
    
    func add(_ value: RefValue) {
        self.value.append(value)
    }
}

class RefObject {
    @RawRepresented
    var type: XMLDataType?
    
    var content: RefCollection
    
    init(type: XMLDataType, content: RefCollection = .init()) {
        _type = .init(type)
        self.content = content
    }
    
    init(type: RawRepresented<XMLDataType>, content: RefCollection = .init()) {
        _type = type
        self.content = content
    }
}

extension RefValue {
    convenience init(_ personalDataValue: PersonalDataValue) {
        switch personalDataValue {
            case let .item(string):
                self.init(EncodedValue.item(string))
            case let .collection(collection):
                self.init(.collection(RefCollection(collection)))
            case let .list(list):
                self.init(.list(RefList(list)))
            case let .object(object):
                self.init(.object(RefObject(object)))
        }
    }
    
    func personalDataValue() -> PersonalDataValue? {
        switch value {
            case let .item(string):
                return .item(string)
            case let .collection(collection):
                return .collection(collection.personalPersonalDataCollection())
            case let .list(list):
                return .list(list.personalPersonalDataList())
            case let .object(object):
                return .object(object.personalPersonalDataObject())
            case .none:
                return nil
        }
    }
}

extension RefCollection {
    convenience init(_ collection: PersonalDataCollection) {
        self.init(collection.mapValues { RefValue($0) })
    }
    
    func personalPersonalDataCollection() -> PersonalDataCollection {
        value.compactMapValues { $0.personalDataValue() }
    }
}

extension RefList {
    convenience init(_ list: PersonalDataList) {
        self.init(list.map { RefValue($0) })
    }
    
    func personalPersonalDataList() -> PersonalDataList {
        value.compactMap { $0.personalDataValue() }
    }
}

extension RefObject {
    convenience init(_ object: PersonalDataObject) {
        self.init(type: .init(rawValue: object.$type), content: RefCollection(object.content))
    }
    
    func personalPersonalDataObject() -> PersonalDataObject {
        PersonalDataObject.init(type: _type, content: content.personalPersonalDataCollection())
    }
}
