import Foundation
import IconLibrary
import CorePersonalData
import DashTypes

extension DomainIconViewModel {
    public init(credential: Credential, size: IconStyle.SizeType, iconService: IconServiceProtocol) {
        self.init(domain: credential.url?.domain, size: size, iconService: iconService)
    }

    public init(personalDataURL: PersonalDataURL, size: IconStyle.SizeType, iconService: IconServiceProtocol) {
        self.init(domain: personalDataURL.domain, size: size, iconService: iconService)
    }

    public init(domain: Domain?, size: IconStyle.SizeType, iconService: IconServiceProtocol) {
        self.init(domain: domain, size: size, iconLibrary: iconService.domain)
    }
}
