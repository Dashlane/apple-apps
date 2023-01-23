import Foundation
import DashTypes

struct RecipientsConfiguration {
   var userEmails: Set<String> = []
   var groupIds: Set<Identifier> = []
   var permission: SharingPermission = .limited
}

extension RecipientsConfiguration {
    var count: Int {
        groupIds.count + userEmails.count
    }

    var isEmpty: Bool {
        groupIds.isEmpty && userEmails.isEmpty
    }
}
