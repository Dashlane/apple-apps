import SwiftUI
import CorePersonalData
import IconLibrary
import DashTypes

public class VaultItemIconViewModel {
    public let item: VaultItem
    public let iconLibrary: DomainIconLibraryProtocol

    public init(item: VaultItem, iconService: IconServiceProtocol) {
        self.item = item
        self.iconLibrary = iconService.domain
    }
    
    public init(item: VaultItem, iconLibrary: DomainIconLibraryProtocol) {
        self.item = item
        self.iconLibrary = iconLibrary
    }
    
    public func makeDomainIconViewModel(credential: Credential, size: IconStyle.SizeType) -> DomainIconViewModel  {
        return DomainIconViewModel(domain: credential.url?.domain,
                                   size: size,
                                   iconLibrary: iconLibrary)
    }
}

extension VaultItemIconViewModel {
    public static func mock(item: VaultItem, icon: Icon? = nil) -> VaultItemIconViewModel {
        return VaultItemIconViewModel(item: item, iconLibrary: FakeDomainIconLibrary(icon: icon))
    }
}
