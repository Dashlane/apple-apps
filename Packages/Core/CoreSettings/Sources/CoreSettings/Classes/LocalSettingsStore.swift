import Foundation
import DashTypes

public protocol LocalSettingsStore {
    typealias Identifier = String
    func set<T: DataConvertible>(value: T?, forIdentifier: Identifier)
    func value<T: DataConvertible>(for: Identifier) -> T?
    func delete(_ identifier: Identifier)
    func registerIfneeded(_ settingRegistrations: [SettingRegistration])
}

extension Settings: LocalSettingsStore {
    public func registerIfneeded(_ settingRegistrations: [SettingRegistration]) {
        settingRegistrations.forEach {
                        try? register.append($0)
        }
    }
}

extension SettingRegistration {
    init<Key: LocalSettingsKey>(key: Key) {
        self.init(identifier: key.identifier, type: key.type, secure: key.isEncrypted)
    }
}

extension DataConvertible where Self: RawRepresentable, Self.RawValue == String  {
    public var binaryData: Data {
        return self.rawValue.binaryData
    }
    
    public init?(binaryData: Data) {
        guard let string = String(binaryData: binaryData) else {
            return nil
        }
        self.init(rawValue: string)
    }
}

extension DataConvertible where Self: RawRepresentable, Self.RawValue == Int  {
    public var binaryData: Data {
        return self.rawValue.binaryData
    }

    public init?(binaryData: Data) {
        guard let int = Int(binaryData: binaryData) else {
            return nil
        }
        self.init(rawValue: int)
    }
}

public class InMemoryLocalSettingsStore: LocalSettingsStore {

    
    var data: [String: Any]
    
    public init() {
      data = [:]
    }
    
    public func set<T>(value: T?, forIdentifier identifier: LocalSettingsStore.Identifier) where T : DataConvertible {
        data[identifier] = value
    }
    
    public func value<T>(for identifier: LocalSettingsStore.Identifier) -> T? where T : DataConvertible {
        return data[identifier] as? T
    }
    
    public func delete(_ identifier: LocalSettingsStore.Identifier) {
        data.removeValue(forKey: identifier)
    }
    
    public func registerIfneeded(_ settingRegistrations: [SettingRegistration]) {
        
    }
}
