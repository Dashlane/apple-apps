import CorePersonalData
import CoreSharing
import SwiftUI

struct VaultItemsListDeleteKey: EnvironmentKey {
  static var defaultValue: ItemsListDelete?
}

struct VaultItemsListDeleteBehaviourKey: EnvironmentKey {
  static var defaultValue: ItemsListDeleteBehaviour = .init { _ in .normal }
}

extension EnvironmentValues {
  public var vaultItemsListDelete: ItemsListDelete? {
    get { self[VaultItemsListDeleteKey.self] }
    set { self[VaultItemsListDeleteKey.self] = newValue }
  }

  public var vaultItemsListDeleteBehaviour: ItemsListDeleteBehaviour {
    get { self[VaultItemsListDeleteBehaviourKey.self] }
    set { self[VaultItemsListDeleteBehaviourKey.self] = newValue }
  }
}

extension View {
  public func vaultItemsListDelete(_ delete: ItemsListDelete) -> some View {
    self.environment(\.vaultItemsListDelete, delete)
  }

  public func vaultItemsListDeleteBehaviour(_ behaviour: ItemsListDeleteBehaviour) -> some View {
    self.environment(\.vaultItemsListDeleteBehaviour, behaviour)
  }
}

public struct ItemsListDelete {
  private let delete: (VaultItem) -> Void

  public init(_ delete: @escaping (VaultItem) -> Void) {
    self.delete = delete
  }

  public func callAsFunction(_ item: VaultItem) {
    delete(item)
  }
}

public struct ItemsListDeleteBehaviour {

  private let behaviour: (VaultItem) async throws -> ItemDeleteBehaviour

  public init(_ behaviour: @escaping (VaultItem) async throws -> ItemDeleteBehaviour) {
    self.behaviour = behaviour
  }

  public func callAsFunction(_ item: VaultItem) async throws -> ItemDeleteBehaviour {
    try await behaviour(item)
  }
}
