import CorePersonalData
import CoreSharing
import CoreSync
import DashTypes
import Foundation

public protocol SharingSyncHandler {
  var manualSyncHandler: () -> Void { get set }
  func sync(using sharingInfo: SharingSummaryInfo?) async throws
}

public protocol SharedVaultHandling: SharingSyncHandler {
  func permission(for item: PersonalDataCodable) -> SharingPermission?
  func deleteBehaviour(for item: PersonalDataCodable) async throws -> ItemDeleteBehaviour
  func deleteBehaviour(for id: Identifier) async throws -> ItemDeleteBehaviour

  func refuseAndDelete(_ item: PersonalDataCodable) async throws
}

extension SharingPermission {
  public var canCopy: Bool {
    return self != .limited
  }

  public var canModify: Bool {
    return self != .limited
  }
}

extension SharedVaultHandling {
  public func canCopyProperties(in item: PersonalDataCodable) -> Bool {
    guard item.isShared, let permission = permission(for: item) else {
      return true
    }

    return permission.canCopy
  }
}

public struct SharedVaultHandlerMock: SharedVaultHandling {
  public let permission: SharingPermission
  public let deleteBehaviour: ItemDeleteBehaviour
  public var manualSyncHandler: () -> Void = {}

  public init(
    permission: SharingPermission = .admin,
    deleteBehaviour: ItemDeleteBehaviour = .canDeleteByLeavingItemGroup
  ) {
    self.permission = permission
    self.deleteBehaviour = deleteBehaviour
  }

  public func permission(for item: PersonalDataCodable) -> SharingPermission? {
    return permission
  }

  public func deleteBehaviour(for item: PersonalDataCodable) async -> ItemDeleteBehaviour {
    return deleteBehaviour
  }

  public func deleteBehaviour(for id: Identifier) async -> ItemDeleteBehaviour {
    return deleteBehaviour
  }

  public func refuseAndDelete(_ item: PersonalDataCodable) async {

  }

  public func sync(using sharingInfo: SharingSummaryInfo?) async {

  }
}
