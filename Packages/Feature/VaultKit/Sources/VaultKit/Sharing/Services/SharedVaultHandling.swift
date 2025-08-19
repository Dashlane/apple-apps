import CorePersonalData
import CoreSharing
import CoreSync
import CoreTypes
import Foundation

public protocol SharedVaultHandling: SharingSyncHandler {
  func permission(for item: VaultItem) -> SharingPermission?
  func deleteBehaviour(for item: VaultItem) async throws -> ItemDeleteBehaviour
  func deleteBehaviour(for id: Identifier) async throws -> ItemDeleteBehaviour

  func refuseAndDelete(_ item: VaultItem) async throws
}

extension SharedVaultHandling {
  public func canCopyProperties(in item: VaultItem) -> Bool {
    guard item.isShared, let permission = permission(for: item) else {
      return true
    }

    return permission.canCopy
  }
}

extension SharingPermission {
  public var canCopy: Bool {
    return self != .limited
  }

  public var canModify: Bool {
    return self != .limited
  }
}

public final class SharedVaultHandlerMock: SharedVaultHandling {
  public let permission: SharingPermission
  public let deleteBehaviour: ItemDeleteBehaviour
  public var manualSyncHandler: () -> Void = {}
  public var lastSharingInfo: SharingSummaryInfo?
  public var deletedItem: VaultItem?

  public init(
    permission: SharingPermission = .admin,
    deleteBehaviour: ItemDeleteBehaviour = .canDeleteByLeavingItemGroup
  ) {
    self.permission = permission
    self.deleteBehaviour = deleteBehaviour
  }

  public func permission(for item: VaultItem) -> SharingPermission? {
    return permission
  }

  public func deleteBehaviour(for item: VaultItem) async -> ItemDeleteBehaviour {
    return deleteBehaviour
  }

  public func deleteBehaviour(for id: Identifier) async -> ItemDeleteBehaviour {
    return deleteBehaviour
  }

  public func refuseAndDelete(_ item: VaultItem) async {
    deletedItem = item
  }

  public func sync(using sharingInfo: SharingSummaryInfo?) async {
    lastSharingInfo = sharingInfo
  }
}

extension SharedVaultHandling where Self == SharedVaultHandlerMock {
  public static func mock(
    permission: SharingPermission = .admin,
    deleteBehaviour: ItemDeleteBehaviour = .canDeleteByLeavingItemGroup
  ) -> Self {
    SharedVaultHandlerMock(permission: permission, deleteBehaviour: deleteBehaviour)
  }
}
