import Foundation
import GRDB

extension DerivableRequest where RowDecoder: SharingGroupMember {
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
