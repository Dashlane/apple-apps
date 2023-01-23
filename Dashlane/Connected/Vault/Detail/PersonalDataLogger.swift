import Foundation
import DashlaneReportKit
import CorePersonalData
import DashlaneAppKit
import VaultKit

struct VaultItemLogger {
    let usageLogService: UsageLogServiceProtocol
    let vaultItemsService: VaultItemsServiceProtocol
    let teamSpacesService: TeamSpacesService

        func logUpdate<ItemType: VaultItem>(for item: ItemType,
                                        isDeleting: Bool = false,
                                        from origin: UsageLogCode11PersonalData.FromType?) {
        let action: UsageLogCode11PersonalData.ActionType = isDeleting ? .remove : (item.metadata.id.isTemporary ? .add : .edit)
        var counter = try? vaultItemsService.count(for: ItemType.self)
        if isDeleting {
            counter? -= 1
        }

        let spaceId = teamSpacesService.userSpace(for: item)?.anonymousIdForUsageLogs

        let log = UsageLogCode11PersonalData(country: item.logData.country,
                                             type: item.usageLogType,
                                             action: action,
                                             website: item.logData.website,
                                             counter: counter,
                                             from: origin ?? item.logData.origin,
                                             details: item.logData.details,
                                             color: item.logData.color,
                                             secure: item.logData.secure,
                                             size: item.logData.size,
                                             itemId: item.anonId,
                                             spaceId: spaceId,
                                             category: item.logData.category,
                                             document_count: item.logData.attachmentCount)
        usageLogService.post(log)
    }
}

extension SessionServicesContainer {
    var vaultDetailLogger: VaultItemLogger {
        return VaultItemLogger(usageLogService: activityReporter.legacyUsage, vaultItemsService: vaultItemsService, teamSpacesService: teamSpacesService)
    }
}
