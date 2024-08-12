import Foundation
import GRDB

extension SharingGroupMember where Group.Info: TableRecord, Self: TableRecord {
  static var parent: BelongsToAssociation<Self, Group.Info> {
    belongsTo(Group.Info.self)
  }
}

extension DerivableRequest where RowDecoder: SharingGroupMember {
  func filter(status: SharingMemberStatus) -> Self {
    filter(Column.status == status.rawValue)
  }

  func filter(status: [SharingMemberStatus]) -> Self {
    filter(status.map(\.rawValue).contains(Column.status))
  }
}

extension DerivableRequest where RowDecoder == SharingCollection {
  func filter(status: SharingMemberStatus) -> Self {
    filter(Column.status == status.rawValue)
  }

  func filter(status: [SharingMemberStatus]) -> Self {
    filter(status.map(\.rawValue).contains(Column.status))
  }
}

extension Column {
  static let status = Column("status")
}
