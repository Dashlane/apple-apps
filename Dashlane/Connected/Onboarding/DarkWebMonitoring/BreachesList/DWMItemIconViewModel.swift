import Combine
import CorePersonalData
import DashTypes
import Foundation
import IconLibrary
import VaultKit

protocol DWMItemIconViewModelProtocol {
  var url: PersonalDataURL { get }
  func makeDomainIconViewModel(size: IconSizeType) -> DomainIconViewModel
}

class DWMItemIconViewModel: DWMItemIconViewModelProtocol, SessionServicesInjecting {
  let url: PersonalDataURL
  let iconService: IconServiceProtocol

  init(url: PersonalDataURL, iconService: IconServiceProtocol) {
    self.url = url
    self.iconService = iconService
  }

  func makeDomainIconViewModel(size: IconSizeType) -> DomainIconViewModel {
    return DomainIconViewModel(personalDataURL: url, size: size, iconService: iconService)
  }
}

struct FakeDWMItemIconViewModel: DWMItemIconViewModelProtocol {
  let url: PersonalDataURL

  func makeDomainIconViewModel(size: IconSizeType) -> DomainIconViewModel {
    return DomainIconViewModel(personalDataURL: url, size: size, iconService: IconServiceMock())
  }
}
