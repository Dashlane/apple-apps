import CorePersonalData
import Foundation

extension VaultItem {
  var sortingDate: Date? {
    userModificationDatetime ?? creationDatetime
  }
}
