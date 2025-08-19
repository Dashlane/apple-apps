import CoreTypes
import Foundation

extension Collection where Element == any SharingGroupMember {
  func computeItemState() -> SharingItemUpdate.State? {
    let membersByStatus = Dictionary(grouping: self) { $0.status }
    let statusToCheck: [SharingMemberStatus] = [.accepted, .pending]
    for status in statusToCheck {
      guard let members = membersByStatus[status] else {
        continue
      }
      let permission: SharingPermission =
        members.contains { $0.permission == .admin } ? .admin : .limited
      return .init(isAccepted: status == .accepted, permission: permission)
    }

    return nil
  }
}
