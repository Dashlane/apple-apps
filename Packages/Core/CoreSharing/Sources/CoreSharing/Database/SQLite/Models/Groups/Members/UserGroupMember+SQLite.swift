import Foundation
import GRDB
import DashTypes

extension UserGroupMember: TableRecord, FetchableRecord, PersistableRecord {
        static let parentItemGroup = belongsTo(ItemGroupInfo.self)
        static let userGroup = belongsTo(UserGroupInfo.self, using: ForeignKey([Column.id]))
}
