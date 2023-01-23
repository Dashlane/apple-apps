import SwiftUI
import CorePersonalData
import Combine
import DashlaneAppKit
import IconLibrary
import VaultKit

struct VaultItemIconView: View {
    
    let model: VaultItemIconViewModel
    
    @ViewBuilder
    var body: some View {
        switch model.item.icon(forListStyle: true) {
            case .credential(let credential):
                DomainIconView(model: model.makeDomainIconViewModel(credential: credential, size: .safariPopover),
                               placeholderTitle: credential.url?.displayDomain ?? credential.title)
            default:
                fatalError("Should not try to show credit cards")
        }
    }
}

extension VaultItemIconView: Equatable {
    static func == (lhs: VaultItemIconView, rhs: VaultItemIconView) -> Bool {
        return lhs.model.item.icon == rhs.model.item.icon
    }
}

extension VaultItem {
    func icon(forListStyle isListStyle: Bool) -> VaultItemIcon {
        return isListStyle ? listIcon : icon
    }
}
