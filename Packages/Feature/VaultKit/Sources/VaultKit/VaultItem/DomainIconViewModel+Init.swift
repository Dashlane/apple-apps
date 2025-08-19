import CorePersonalData
import CoreTypes
import Foundation
import IconLibrary

extension DomainIconViewModel {
  public init(credential: Credential, iconService: IconServiceProtocol) {
    self.init(domain: credential.url?.domain, iconService: iconService)
  }

  public init(personalDataURL: PersonalDataURL, iconService: IconServiceProtocol) {
    self.init(domain: personalDataURL.domain, iconService: iconService)
  }

  public init(domain: Domain?, iconService: IconServiceProtocol) {
    self.init(domain: domain, iconLibrary: iconService.domain)
  }
}
