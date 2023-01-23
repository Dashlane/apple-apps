import Foundation
import SwiftUI
import CoreSync
import Combine
import DashlaneAppKit
import IconLibrary
import VaultKit

protocol CredentialRowViewModelProtocol: ObservableObject, AuthenticatorServicesInjecting, AuthenticatorMockInjecting {
    var item: VaultItem { get }
    func makeIconViewModel() -> VaultItemIconViewModel
}

class CredentialRowViewModel: CredentialRowViewModelProtocol, AuthenticatorServicesInjecting {
    let item: VaultItem
    let domainLibrary: DomainIconLibraryProtocol
    
    init(item: VaultItem,
         domainLibrary: DomainIconLibraryProtocol) {
        self.item = item
        self.domainLibrary = domainLibrary
    }
    
    func makeIconViewModel() -> VaultItemIconViewModel {
        VaultItemIconViewModel(item: item, iconLibrary: domainLibrary)
    }
}
