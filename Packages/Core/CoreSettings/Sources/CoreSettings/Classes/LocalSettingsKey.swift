import Foundation

public protocol LocalSettingsKey: CaseIterable {
    var identifier: String { get }
    var type: Any.Type { get }
    var isEncrypted: Bool { get }
}

public extension LocalSettingsKey {
    var isEncrypted: Bool {
        return false
    }
}

public extension LocalSettingsKey where Self: RawRepresentable, Self.RawValue == String {
    var identifier: String {
        return rawValue
    }
}
