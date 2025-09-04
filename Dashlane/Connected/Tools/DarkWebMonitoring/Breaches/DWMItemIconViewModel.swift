import Combine
import CorePersonalData
import CoreTypes
import Foundation
import IconLibrary
import VaultKit

protocol DWMItemIconViewModelProtocol {
  var url: PersonalDataURL { get }
  func makeDomainIconViewModel() -> DomainIconViewModel
}

class DWMItemIconViewModel: DWMItemIconViewModelProtocol, SessionServicesInjecting {
  let url: PersonalDataURL
  let iconService: IconServiceProtocol

  init(url: PersonalDataURL, iconService: IconServiceProtocol) {
    self.url = url
    self.iconService = iconService
  }

  func makeDomainIconViewModel() -> DomainIconViewModel {
    return DomainIconViewModel(personalDataURL: url, iconService: iconService)
  }
}

struct FakeDWMItemIconViewModel: DWMItemIconViewModelProtocol {
  let url: PersonalDataURL

  func makeDomainIconViewModel() -> DomainIconViewModel {
    return DomainIconViewModel(personalDataURL: url, iconService: IconServiceMock())
  }
}
