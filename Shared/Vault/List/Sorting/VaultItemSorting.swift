import Foundation
import DashlaneAppKit
import CoreSettings

extension VaultItemSorting {
    var title: String {
        switch self {
        case .sortedByName:
            return L10n.Localizable.kwSortByName
        case .sortedByCategory:
            return L10n.Localizable.kwSortByCategory
        }
    }
}
