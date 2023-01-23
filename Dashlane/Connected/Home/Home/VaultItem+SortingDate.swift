import Foundation
import DashlaneAppKit
import VaultKit

extension VaultItem {
    var sortingDate: Date? {
        userModificationDatetime ?? creationDatetime
    }
}
