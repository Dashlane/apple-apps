import Foundation
import CorePremium

extension BusinessTeam {
    public func shouldBeForced(on item: VaultItem) -> Bool {
        guard shouldForceSpace else {
            return false
        }

        return item.isAssociated(to: self)
    }
}
