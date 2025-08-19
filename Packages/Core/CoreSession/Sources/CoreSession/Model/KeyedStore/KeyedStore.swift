import Foundation
import LogFoundation

public protocol KeyedStore {
  associatedtype Key: StoreKey

  func exists(for key: Key) -> Bool
  func store(_ data: Data?, for key: Key) throws
  func retrieveData(for key: Key) throws -> Data
}

extension KeyedStore {
  public func store(_ object: String, for key: Key) throws {
    let data = object.data(using: .utf8)
    try store(data, for: key)
  }

  public func retrieveString(for key: Key) throws -> String {
    let data = try retrieveData(for: key)

    guard let string = String(data: data, encoding: .utf8) else {
      throw KeyedStoreError.wrongType(key)
    }
    return string
  }
}

extension KeyedStore {
  public func store<T: FixedWidthInteger>(_ object: T, for key: Key) throws {
    let data = withUnsafeBytes(of: object.littleEndian) { Data($0) }
    try store(data, for: key)
  }

  public func retrieve<T: FixedWidthInteger>(for key: Key) throws -> T {
    let data = try retrieveData(for: key)
    guard data.count == MemoryLayout<T>.size else { throw KeyedStoreError.wrongType(key) }
    let value: T = data.withUnsafeBytes { $0.load(as: T.self) }

    return value.littleEndian
  }
}

extension KeyedStore {
  public func store<T: Encodable>(_ object: T?, for key: Key) throws {
    guard let object = object else {
      try store(nil, for: key)
      return
    }

    let data: Data
    do {
      data = try JSONEncoder().encode(object)
    } catch EncodingError.invalidValue {
      data = try JSONEncoder().encode(EncodableWrapper<T>(value: object))
    }
    try store(data, for: key)
  }

  public func retrieve<T: Decodable>(_ type: T.Type, for key: Key) throws -> T {
    let data = try retrieveData(for: key)

    let object: T

    do {
      object = try JSONDecoder().decode(type, from: data)
    } catch EncodingError.invalidValue {
      object = try JSONDecoder().decode(DecodableWrapper<T>.self, from: data).value
    }
    return object
  }
}

extension KeyedStore {
  public func store(_ bool: Bool, for key: Key) throws {
    let data = Data([UInt8(bool ? 1 : 0)])
    try store(data, for: key)
  }

  public func retrieve(for key: Key) throws -> Bool {
    let data = try retrieveData(for: key)
    return [UInt8](data).first == 0x01
  }
}

@Loggable
public enum KeyedStoreError: Error {
  case noValue(StoreKey)
  case wrongType(StoreKey)
}

struct EncodableWrapper<E: Encodable>: Encodable {
  let value: E
}

struct DecodableWrapper<D: Decodable>: Decodable {
  let value: D
}
