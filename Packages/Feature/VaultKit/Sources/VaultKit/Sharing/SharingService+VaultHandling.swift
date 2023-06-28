import Foundation
import DashTypes
import CoreSharing
import CoreSync
import CorePersonalData

extension SharingService: SharedVaultHandling {
    public func permission(for item: PersonalDataCodable) -> SharingPermission? {
        guard item.isShared else {
            return nil
        }
        return item.metadata.sharingPermission
    }

    public func deleteBehaviour(for item: PersonalDataCodable) async throws -> ItemDeleteBehaviour {
        return try engine.deleteBehaviour(forItemId: item.id)
    }

    public func refuseAndDelete(_ item: CorePersonalData.PersonalDataCodable) async throws {
        let auditLogDetails = try? activityLogsService.makeActivityLog(codable: item)
        try await engine.refuseItem(with: item.id, userAuditLogDetails: auditLogDetails)
    }

    public func forceRevoke(_ credentials: [CorePersonalData.Credential]) async throws {
        try await engine.forceRevokeItemGroup(withItemIds: credentials.map(\.id))
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

        try await engine.update(from: SharingSummary(items: .init(summary.items),
                                                     itemGroups: .init(summary.itemGroups),
                                                     userGroups: .init(summary.userGroups)))
    }
}

extension Dictionary where Key == Identifier, Value == SharingTimestamp {
    init(_ summaries: [CoreSync.ItemSummary]) {
        self.init(summaries.map { (.init($0.id), $0.timestamp) }, uniquingKeysWith: Swift.max)
    }
}

extension Dictionary where Key == Identifier, Value == SharingRevision {
    init(_ summaries: [CoreSync.GroupSummary]) {
        self.init(summaries.map { (.init($0.id), $0.revision) }, uniquingKeysWith: Swift.max)
    }
}
