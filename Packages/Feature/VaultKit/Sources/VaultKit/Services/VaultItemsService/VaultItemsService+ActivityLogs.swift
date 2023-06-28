import Foundation
import CoreActivityLogs
import CorePersonalData

extension VaultItemsService {

    public func activityLogSave(_ item: VaultItem) {
        guard activityLogsService.isCollectionEnabled else { return }
        guard let info = item.reportableInfo() else { return }
        try? activityLogsService.report(item.isSaved ? .update : .creation,
                                        for: info)
    }

    func activityLogSave(_ items: [VaultItem]) {
        guard activityLogsService.isCollectionEnabled else { return }
        for item in items {
            guard let info = item.reportableInfo() else { return }
            try? activityLogsService.report(item.isSaved ? .update : .creation,
                                             for: info)
        }
    }
}

extension VaultItemsService {

    func activityLogDelete(_ item: VaultItem) {
        guard activityLogsService.isCollectionEnabled else { return }
        guard let info = item.reportableInfo() else { return }
        try? activityLogsService.report(.deletion, for: info)
    }

}
