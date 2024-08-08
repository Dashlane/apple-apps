import CorePersonalData
import CoreSharing
import CoreSync
import DashTypes
import Foundation

extension SharingService: SharedVaultHandling {
  public func permission(for item: PersonalDataCodable) -> SharingPermission? {
    guard item.isShared else {
      return nil
    }
    return item.metadata.sharingPermission
  }

  public func deleteBehaviour(for id: Identifier) async throws -> ItemDeleteBehaviour {
    return try engine.deleteBehaviour(forItemId: id)
  }

  public func deleteBehaviour(for item: PersonalDataCodable) async throws -> ItemDeleteBehaviour {
    return try engine.deleteBehaviour(forItemId: item.id)
  }

  public func refuseAndDelete(_ item: CorePersonalData.PersonalDataCodable) async throws {
    let auditLogDetails = try? activityLogsService.makeActivityLog(codable: item)
    try await engine.refuseItem(with: item.id, userAuditLogDetails: auditLogDetails)
  }

  @SharingActor
  public func sync(using sharingInfo: SharingSummaryInfo?) async throws {
    defer {
      isReady = true
    }
    if engine.needsKey, let key = await keysStore.keyPair() {
      try await engine.updateUserKey(key)
    }

    guard !engine.needsKey, let summary = sharingInfo else {
      return
    }

    try await engine.update(from: (SharingSummary(summary)))
  }
}

extension SharingSummary {
  init(_ sharingInfo: SharingSummaryInfo) {
    self.init(
      items: sharingInfo.items.reduce(into: [Identifier: SharingTimestamp]()) {
        $0[Identifier($1.id)] = $1.timestamp
      },
      itemGroups: sharingInfo.itemGroups.reduce(into: [Identifier: SharingRevision]()) {
        $0[Identifier($1.id)] = $1.revision
      },
      userGroups: sharingInfo.userGroups.reduce(into: [Identifier: SharingRevision]()) {
        $0[Identifier($1.id)] = $1.revision
      },
      collections: sharingInfo.collections.reduce(into: [Identifier: SharingRevision]()) {
        $0[Identifier($1.id)] = $1.revision
      }
    )
  }
}
