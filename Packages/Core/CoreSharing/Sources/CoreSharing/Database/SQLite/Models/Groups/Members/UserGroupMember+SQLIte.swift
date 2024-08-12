import DashTypes
import Foundation
import GRDB

extension UserGroupMember: TableRecord, FetchableRecord, PersistableRecord {}

extension UserGroupMember where Group.Info: TableRecord & FetchableRecord & PersistableRecord {
  static var userGroup: BelongsToAssociation<UserGroupMember<Group>, UserGroupInfo> {
    belongsTo(UserGroupInfo.self, using: ForeignKey([Column.id]))
  }
}
