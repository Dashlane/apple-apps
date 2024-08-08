import CorePersonalData
import DashTypes
import Foundation
import IconLibrary

extension DomainIconViewModel {
  public init(credential: Credential, size: IconSizeType, iconService: IconServiceProtocol) {
    self.init(domain: credential.url?.domain, size: size, iconService: iconService)
  }

  public init(
    personalDataURL: PersonalDataURL, size: IconSizeType, iconService: IconServiceProtocol
  ) {
    self.init(domain: personalDataURL.domain, size: size, iconService: iconService)
  }

  public init(domain: Domain?, size: IconSizeType, iconService: IconServiceProtocol) {
    self.init(domain: domain, size: size, iconLibrary: iconService.domain)
  }
}
