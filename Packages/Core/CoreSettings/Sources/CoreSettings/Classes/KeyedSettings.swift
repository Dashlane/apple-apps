@preconcurrency import Combine
import CoreTypes
import Foundation

public struct KeyedSettings<Key: LocalSettingsKey>: Sendable {
  public let internalStore: LocalSettingsStore
  public let settingsChangePublisher = PassthroughSubject<Key, Never>()
  public let prefix: String?

  public init(
    internalStore: LocalSettingsStore,
    withPrefix prefix: String? = nil
  ) {
    self.internalStore = internalStore
    self.prefix = prefix
    internalStore.register(Key.self, withPrefix: prefix)
  }
}

extension KeyedSettings {
  public nonmutating func settingsChangePublisher(key: Key) -> AnyPublisher<Void, Never> {
    return settingsChangePublisher.filter {
      $0.identifier == key.identifier.prefixed(with: self.prefix)
    }
    .map { _ in Void() }
    .eraseToAnyPublisher()
  }

  public nonmutating func changeMonitoringPublisher<T: DataConvertible>(key: Key) -> AnyPublisher<
    T?, Never
  > {
    return settingsChangePublisher.filter {
      $0.identifier == key.identifier.prefixed(with: self.prefix)
    }
    .map { return self[$0] }
    .eraseToAnyPublisher()
  }

  public nonmutating func publisher<T: DataConvertible>(for key: Key) -> AnyPublisher<T?, Never> {
    return changeMonitoringPublisher(key: key)
      .prepend(self[key])
      .eraseToAnyPublisher()
  }

  public nonmutating func deleteValue(for key: Key) {
    self.internalStore.delete(key.identifier.prefixed(with: self.prefix))
    settingsChangePublisher.send(key)
  }

  public subscript<T: DataConvertible>(key: Key) -> T? {
    get {
      return internalStore.value(for: key.identifier.prefixed(with: self.prefix))
    }
    nonmutating set {
      guard let newValue = newValue else {
        self.deleteValue(for: key)
        return
      }
      internalStore.set(value: newValue, forIdentifier: key.identifier.prefixed(with: self.prefix))
      settingsChangePublisher.send(key)
    }
  }
}

extension LocalSettingsStore {
  public func keyed<Key: LocalSettingsKey>(by key: Key.Type) -> KeyedSettings<Key> {
    return KeyedSettings(internalStore: self)
  }
}

extension LocalSettingsStore {
  public func register<Key>(_ key: Key.Type, withPrefix prefix: String? = nil)
  where Key: LocalSettingsKey {
    registerIfneeded(
      Key.allCases.map { key -> SettingRegistration in
        SettingRegistration.init(
          identifier: key.identifier.prefixed(with: prefix),
          type: key.type,
          secure: key.isEncrypted)
      })
  }
}

extension String {
  fileprivate func prefixed(with prefix: String?) -> String {
    if let prefix = prefix, !prefix.isEmpty {
      return "\(prefix)-\(self)"
    } else {
      return self
    }
  }
}
