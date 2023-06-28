import CoreLocalization
import DesignSystem
import SwiftUI

struct VaultItemRowCollectionActionsKey: EnvironmentKey {
    static var defaultValue: [VaultItemRowCollectionActionType] = []
}

struct VaultItemRowEditActionKey: EnvironmentKey {
    static var defaultValue: VaultItemRowAction?
}

public extension EnvironmentValues {
    var vaultItemRowCollectionActions: [VaultItemRowCollectionActionType] {
        get { self[VaultItemRowCollectionActionsKey.self] }
        set { self[VaultItemRowCollectionActionsKey.self] = newValue }
    }

    var vaultItemRowEditAction: VaultItemRowAction? {
        get { self[VaultItemRowEditActionKey.self] }
        set { self[VaultItemRowEditActionKey.self] = newValue }
    }
}

public extension View {
            func vaultItemRowCollectionActions(_ actions: [VaultItemRowCollectionActionType]) -> some View {
        self.environment(\.vaultItemRowCollectionActions, actions)
    }

            func vaultItemRowEditAction(_ action: VaultItemRowAction) -> some View {
        self.environment(\.vaultItemRowEditAction, action)
    }
}

public enum VaultItemRowCollectionActionType: Identifiable, Equatable {
        case addToACollection

        case removeFromACollection

        case removeFromThisCollection(VaultItemRowAction)

    public var id: String { title }

    public var image: Image {
        switch self {
        case .addToACollection:
            return .ds.folder.outlined
        case .removeFromACollection, .removeFromThisCollection:
            return .ds.action.close.outlined
        }
    }

    public var title: String {
        switch self {
        case .addToACollection:
            return L10n.Core.KWVaultItem.Collections.Actions.addToACollection
        case .removeFromACollection:
            return L10n.Core.KWVaultItem.Collections.Actions.removeFromACollection
        case .removeFromThisCollection:
            return L10n.Core.KWVaultItem.Collections.Actions.removeFromThisCollection
        }
    }
}

public struct VaultItemRowAction: Identifiable, Equatable {

    public let id: UUID
    private let action: () -> Void

    public init(_ action: @escaping () -> Void) {
        self.id = UUID()
        self.action = action
    }

    public func callAsFunction() {
        action()
    }

    public static func == (lhs: VaultItemRowAction, rhs: VaultItemRowAction) -> Bool {
        return lhs.id == rhs.id
    }
}
