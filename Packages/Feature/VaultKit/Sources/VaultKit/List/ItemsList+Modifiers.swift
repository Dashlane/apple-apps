import CoreSharing
import SwiftUI

struct VaultItemsListHeaderViewKey: EnvironmentKey {
    static var defaultValue: AnyView?
}

struct VaultItemsListFloatingHeaderViewKey: EnvironmentKey {
    static var defaultValue: AnyView?
}

struct VaultItemsListDeleteKey: EnvironmentKey {
    static var defaultValue: ItemsListDelete?
}

struct VaultItemsListDeleteBehaviourKey: EnvironmentKey {
    static var defaultValue: ItemsListDeleteBehaviour = .init { _ in .normal }
}

public extension EnvironmentValues {
    var vaultItemsListHeaderView: AnyView? {
        get { self[VaultItemsListHeaderViewKey.self] }
        set { self[VaultItemsListHeaderViewKey.self] = newValue }
    }

    var vaultItemsListFloatingHeaderView: AnyView? {
        get { self[VaultItemsListFloatingHeaderViewKey.self] }
        set { self[VaultItemsListFloatingHeaderViewKey.self] = newValue }
    }

    var vaultItemsListDelete: ItemsListDelete? {
        get { self[VaultItemsListDeleteKey.self] }
        set { self[VaultItemsListDeleteKey.self] = newValue }
    }

    var vaultItemsListDeleteBehaviour: ItemsListDeleteBehaviour {
        get { self[VaultItemsListDeleteBehaviourKey.self] }
        set { self[VaultItemsListDeleteBehaviourKey.self] = newValue }
    }
}

public extension View {
            func vaultItemsListHeader(_ view: some View) -> some View {
        self.environment(\.vaultItemsListHeaderView, view.eraseToAnyView())
    }

            func vaultItemsListFloatingHeader(_ view: (some View)?) -> some View {
        self.environment(\.vaultItemsListFloatingHeaderView, view?.eraseToAnyView())
    }

                    func vaultItemsListDelete(_ delete: ItemsListDelete) -> some View {
        self.environment(\.vaultItemsListDelete, delete)
    }

                    func vaultItemsListDeleteBehaviour(_ behaviour: ItemsListDeleteBehaviour) -> some View {
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
