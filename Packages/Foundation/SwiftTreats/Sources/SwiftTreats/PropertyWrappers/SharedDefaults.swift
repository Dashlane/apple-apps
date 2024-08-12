import Foundation

@propertyWrapper
public struct SharedUserDefault<T, Key: CustomStringConvertible> {
  let key: Key
  let defaultValue: T

  let userDefaults: UserDefaults

  public init(key: Key, `default` defaultValue: T, userDefaults: UserDefaults) {
    self.key = key
    self.defaultValue = defaultValue
    self.userDefaults = userDefaults
  }

  public var wrappedValue: T {
    get {
      guard let value = userDefaults.object(forKey: key.description) as? T else {
        return defaultValue
      }
      return value
    }
    set {
      if let value = newValue as? OptionalProtocol, value.isNil() {
        userDefaults.removeObject(forKey: key.description)
      } else {
        userDefaults.set(newValue, forKey: key.description)
      }
    }
  }
}

extension SharedUserDefault {
  public init<P>(key: Key, `default` defaultValue: P? = nil, userDefaults: UserDefaults)
  where T == P? {
    self.key = key
    self.defaultValue = defaultValue
    self.userDefaults = userDefaults
  }
}

private protocol OptionalProtocol {
  func isNil() -> Bool
}

extension Optional: OptionalProtocol {
  func isNil() -> Bool {
    return self == nil
  }
}
