import SwiftUI
import IconLibrary
import Combine
import DashlaneAppKit
import VaultKit

protocol CredentialRowViewModelProtocol: ObservableObject {
    var item: VaultItem { get }
    var highlightedString: String? { get }
    func makeVaultItemIconViewModel() -> VaultItemIconViewModel
}

class CredentialRowViewModel: CredentialRowViewModelProtocol {
    let item: VaultItem
    let domainLibrary: DomainIconLibrary
    let highlightedString: String?
    
    init(item: VaultItem,
         domainLibrary: DomainIconLibrary,
         highlightedString: String? = nil) {
        self.item = item
        self.domainLibrary = domainLibrary
        self.highlightedString = highlightedString
    }
    
    func makeVaultItemIconViewModel() -> VaultItemIconViewModel {
        VaultItemIconViewModel(item: item, iconLibrary: domainLibrary)
    }
}
