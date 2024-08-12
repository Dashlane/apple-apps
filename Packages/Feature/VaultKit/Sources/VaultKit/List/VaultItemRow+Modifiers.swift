import CoreLocalization
import DesignSystem
import SwiftUI

struct VaultItemRowCollectionActionsKey: EnvironmentKey {
  static var defaultValue: [VaultItemRowCollectionActionType] = []
}

struct VaultItemRowEditActionKey: EnvironmentKey {
  static var defaultValue: VaultItemRowAction?
}

extension EnvironmentValues {
  public var vaultItemRowCollectionActions: [VaultItemRowCollectionActionType] {
    get { self[VaultItemRowCollectionActionsKey.self] }
    set { self[VaultItemRowCollectionActionsKey.self] = newValue }
  }

  public var vaultItemRowEditAction: VaultItemRowAction? {
    get { self[VaultItemRowEditActionKey.self] }
    set { self[VaultItemRowEditActionKey.self] = newValue }
  }
}

extension View {
  public func vaultItemRowCollectionActions(_ actions: [VaultItemRowCollectionActionType])
    -> some View
  {
    self.environment(\.vaultItemRowCollectionActions, actions)
  }

  public func vaultItemRowEditAction(_ action: VaultItemRowAction) -> some View {
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
  public let isEnabled: Bool
  private let action: () -> Void

  public init(
    isEnabled: Bool = true,
    _ action: @escaping () -> Void
  ) {
    self.id = UUID()
    self.isEnabled = isEnabled
    self.action = action
  }

  public func callAsFunction() {
    action()
  }

  public static func == (lhs: VaultItemRowAction, rhs: VaultItemRowAction) -> Bool {
    return lhs.id == rhs.id
  }
}

struct VaultItemRowShowSharingInfoKey: EnvironmentKey {
  static var defaultValue: Bool = true
}

extension EnvironmentValues {
  public var vaultItemRowShowSharingInfo: Bool {
    get { self[VaultItemRowShowSharingInfoKey.self] }
    set { self[VaultItemRowShowSharingInfoKey.self] = newValue }
  }
}

extension View {
  public func vaultItemRowHideSharing() -> some View {
    self.environment(\.vaultItemRowShowSharingInfo, false)
  }
}
