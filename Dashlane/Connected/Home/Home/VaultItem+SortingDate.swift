import Foundation
import VaultKit

extension VaultItem {
  var sortingDate: Date? {
    userModificationDatetime ?? creationDatetime
  }
}
