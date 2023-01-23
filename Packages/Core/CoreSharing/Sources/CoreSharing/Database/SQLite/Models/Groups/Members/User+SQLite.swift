import Foundation
import GRDB
import DashTypes

extension User: TableRecord, FetchableRecord, PersistableRecord{
    static let parentItemGroup = belongsTo(ItemGroupInfo.self)
    static let parentUserGroup = belongsTo(UserGroupInfo.self)
}
