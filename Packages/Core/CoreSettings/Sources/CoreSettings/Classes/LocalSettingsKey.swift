import Foundation

public protocol LocalSettingsKey: CaseIterable {
  var identifier: String { get }
  var type: Any.Type { get }
  var isEncrypted: Bool { get }
}

extension LocalSettingsKey {
  public var isEncrypted: Bool {
    return false
  }
}

extension LocalSettingsKey where Self: RawRepresentable, Self.RawValue == String {
  public var identifier: String {
    return rawValue
  }
}
