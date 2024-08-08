import Foundation

public protocol StoreKey {
  var keyString: String { get }
}

extension RawRepresentable where Self: StoreKey, RawValue == String {
  public var keyString: String { return rawValue }
}

extension String: StoreKey {
  public var keyString: String { return self }
}
