import Foundation
import CorePersonalData
import CoreActivityLogs

extension Credential: ActivityLogReportableItem {

    public func reportableInfo() -> ActivityLogReportableInfo? {
        return .init(spaceId: spaceId,
                     createdItemActivityLog: .userCreatedCredential,
                     updatedItemActivityLog: .userModifiedCredential,
                     deletedItemActivityLog: .userDeletedCredential,
                     properties: .init(domainURL: url?.displayDomain ?? title))
    }
}
