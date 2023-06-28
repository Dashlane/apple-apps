import Foundation
import CorePersonalData
import Combine
import DashlaneAppKit
import SwiftUI
import IconLibrary
import VaultKit

struct CredentialItemIconView: View {

    let model: VaultItemIconViewModel

    init(model: @autoclosure () -> (VaultItemIconViewModel)) {
        self.model = model()
    }

    @ViewBuilder
    var body: some View {
        switch model.item.icon(forListStyle: true) {
            case .credential(let credential):
                DomainIconView(model: model.makeDomainIconViewModel(credential: credential, size: .small),
                               placeholderTitle: credential.displayTitle)

            default:
                fatalError("Should not try to show credit cards")
        }
    }
}

extension CredentialItemIconView: Equatable {
    static func == (lhs: CredentialItemIconView, rhs: CredentialItemIconView) -> Bool {
        return lhs.model.item.icon == rhs.model.item.icon
    }
}

extension VaultItem {
    func icon(forListStyle isListStyle: Bool) -> VaultItemIcon {
        return isListStyle ? listIcon : icon
    }
}
