import CoreSharing
import SwiftUI
import VaultKit

struct VaultItemsListHeaderViewKey: EnvironmentKey {
    static var defaultValue: AnyView? = nil
}

struct VaultItemsListFloatingHeaderViewKey: EnvironmentKey {
    static var defaultValue: AnyView? = nil
}

struct VaultItemsListDeleteKey: EnvironmentKey {
    static var defaultValue: ItemsListDelete? = nil
}

struct VaultItemsListDeleteBehaviourKey: EnvironmentKey {
    static var defaultValue: ItemsListDeleteBehaviour = .init { _ in .normal }
}

extension EnvironmentValues {
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

extension View {
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

struct ItemsListDelete {
    private let delete: (VaultItem) -> Void

    init(_ delete: @escaping (VaultItem) -> Void) {
        self.delete = delete
    }

    func callAsFunction(_ item: VaultItem) {
        delete(item)
    }
}

struct ItemsListDeleteBehaviour {

    private let behaviour: (VaultItem) async throws -> ItemDeleteBehaviour

    init(_ behaviour: @escaping (VaultItem) async throws -> ItemDeleteBehaviour) {
        self.behaviour = behaviour
    }

    func callAsFunction(_ item: VaultItem) async throws -> ItemDeleteBehaviour {
        try await behaviour(item)
    }
}
