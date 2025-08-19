import CorePersonalData
import CoreTypes
import IconLibrary
import SwiftUI

public struct VaultItemIconViewModel: VaultKitServicesInjecting {
  public let item: VaultItem
  public let iconLibrary: DomainIconLibraryProtocol

  public init(item: VaultItem, domainIconLibrary: DomainIconLibraryProtocol) {
    self.item = item
    self.iconLibrary = domainIconLibrary
  }

  public func makeDomainIconViewModel(credential: Credential) -> DomainIconViewModel {
    return DomainIconViewModel(domain: credential.url?.domain, iconLibrary: iconLibrary)
  }

  public func makeDomainIconViewModel(passkey: Passkey) -> DomainIconViewModel {
    return DomainIconViewModel(domain: passkey.relyingPartyId.domain, iconLibrary: iconLibrary)
  }
}

extension VaultItemIconViewModel {
  public static func mock(item: VaultItem, icon: Icon? = nil) -> VaultItemIconViewModel {
    return VaultItemIconViewModel(item: item, domainIconLibrary: FakeDomainIconLibrary(icon: icon))
  }
}
