import DashTypes
import Foundation

struct RecipientsConfiguration {
  enum SharingType {
    case collection
    case item
  }

  var userEmails: Set<String> = []
  var groupIds: Set<Identifier> = []
  var permission: SharingPermission = .limited
  var sharingType: SharingType = .item
}

extension RecipientsConfiguration {
  var count: Int {
    groupIds.count + userEmails.count
  }

  var isEmpty: Bool {
    groupIds.isEmpty && userEmails.isEmpty
  }
}
