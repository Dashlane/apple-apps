import Combine
import CoreSync
import Foundation
import IconLibrary
import SwiftUI
import VaultKit

protocol CredentialRowViewModelProtocol: ObservableObject, AuthenticatorServicesInjecting,
  AuthenticatorMockInjecting
{
  var item: VaultItem { get }
  func makeIconViewModel() -> VaultItemIconViewModel
}

class CredentialRowViewModel: CredentialRowViewModelProtocol, AuthenticatorServicesInjecting {
  let item: VaultItem
  let domainLibrary: DomainIconLibraryProtocol

  init(
    item: VaultItem,
    domainLibrary: DomainIconLibraryProtocol
  ) {
    self.item = item
    self.domainLibrary = domainLibrary
  }

  func makeIconViewModel() -> VaultItemIconViewModel {
    VaultItemIconViewModel(item: item, domainIconLibrary: domainLibrary)
  }
}
