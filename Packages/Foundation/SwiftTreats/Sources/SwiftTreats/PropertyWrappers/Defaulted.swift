import Foundation

public protocol DefaultingWrapper: Codable {
  associatedtype Value: Codable

  static var defaultValue: Value { get }
  var wrappedValue: Value { get }

  init(_ value: Value)
}

extension DefaultingWrapper {
  public init() {
    self.init(Self.defaultValue)
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    do {
      self.init(try container.decode(Value.self))
    } catch {
      self.init()
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(wrappedValue)
  }
}

extension KeyedDecodingContainer {
  public func decode<Wrapper: DefaultingWrapper>(
    _ type: Wrapper.Type,
    forKey key: Key
  ) throws -> Wrapper {
    (try? decodeIfPresent(type, forKey: key)) ?? Wrapper()
  }
}

public protocol Defaultable {
  static var defaultValue: Self { get }
}

extension Defaultable where Self: RawRepresentable, Self: Codable, RawValue == String {
  public init(from decoder: Decoder) throws {
    guard let rawValue = try? decoder.singleValueContainer().decode(String.self),
      let value = Self.init(rawValue: rawValue)
    else {
      self = Self.defaultValue
      return
    }

    self = value
  }
}

extension Array: Defaultable {
  public static var defaultValue: [Element] {
    []
  }
}
extension Dictionary: Defaultable {
  public static var defaultValue: [Key: Value] {
    [:]
  }
}
extension Set: Defaultable {
  public static var defaultValue: Set<Element> {
    []
  }
}
extension Bool: Defaultable {
  public static var defaultValue: Bool {
    return false
  }
}

@propertyWrapper
public struct Defaulted<V: Codable & Defaultable>: DefaultingWrapper {
  public static var defaultValue: V {
    return V.defaultValue
  }
  public typealias Value = V
  public var wrappedValue: V

  public init(_ value: V) {
    self.wrappedValue = value
  }

  public init() {
    self.init(Value.defaultValue)
  }
}

extension Defaulted: Hashable where Value: Hashable {}
extension Defaulted: Equatable where Value: Equatable {}

extension Defaulted where Value == Bool {
  @propertyWrapper
  public struct False: DefaultingWrapper, Hashable {
    public static var defaultValue: Bool {
      return false
    }
    public var wrappedValue: Bool

    public init(_ value: Bool) {
      self.wrappedValue = value
    }
    public init() { self.wrappedValue = false }
  }

  @propertyWrapper
  public struct True: DefaultingWrapper, Hashable {
    public static var defaultValue: Bool {
      return true
    }
    public var wrappedValue: Bool

    public init(_ value: Bool) {
      self.wrappedValue = value
    }
    public init() { self.wrappedValue = true }
  }
}
