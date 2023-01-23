import Foundation
import CorePersonalData
import Combine
import DashlaneAppKit
import IconLibrary
import VaultKit
import DashTypes

protocol DWMItemIconViewModelProtocol {
    var url: PersonalDataURL { get }
    func makeDomainIconViewModel(size: IconStyle.SizeType) -> DomainIconViewModel
}

class DWMItemIconViewModel: DWMItemIconViewModelProtocol, SessionServicesInjecting {
    let url: PersonalDataURL
    let iconService: IconServiceProtocol

    init(url: PersonalDataURL, iconService: IconService) {
        self.url = url
        self.iconService = iconService
    }

    func makeDomainIconViewModel(size: IconStyle.SizeType) -> DomainIconViewModel {
        return DomainIconViewModel(personalDataURL: url, size: size, iconService: iconService)
    }
}

struct FakeDWMItemIconViewModel: DWMItemIconViewModelProtocol {
    let url: PersonalDataURL

    init(url: PersonalDataURL) {
        self.url = url
    }

    func makeDomainIconViewModel(size: IconStyle.SizeType) -> DomainIconViewModel {
        return DomainIconViewModel(personalDataURL: url, size: size, iconService: IconServiceMock())
    }
}
