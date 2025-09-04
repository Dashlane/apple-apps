import CoreTypes
import Foundation
import SwiftUI

@propertyWrapper
public struct CapabilityState: DynamicProperty {
  private let key: CapabilityKey

  @Environment(\.capabilities)
  var capabilities: [CapabilityKey: CapabilityStatus]

  public var wrappedValue: CapabilityStatus {
    if let state = capabilities[key] {
      return state
    } else {
      return .unavailable
    }
  }

  public init(_ key: CapabilityKey) {
    self.key = key
  }
}

public struct CapabilityStateEnvironmentKey: EnvironmentKey {
  public static var defaultValue: [CapabilityKey: CapabilityStatus] = [:]
}

extension EnvironmentValues {
  public var capabilities: [CapabilityKey: CapabilityStatus] {
    get {
      return self[CapabilityStateEnvironmentKey.self]
    }
    set {
      self[CapabilityStateEnvironmentKey.self] = newValue
    }
  }
}
