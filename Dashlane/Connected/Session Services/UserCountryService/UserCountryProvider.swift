import Foundation
import CoreNetworking
import CoreRegion
import DashlaneAppKit
import DashTypes

class UserCountryProvider {

        var userCountry: UserCountry

    init(regionInformationService: RegionInformationService) {

        let country = (Locale.current as NSLocale).countryCode ?? "US"
        let isEu = regionInformationService.europeanUnionInfo.contains(countryCode: country)

        userCountry = UserCountry(country: country, isEu: isEu)
    }

        public func load(ukiBasedWebService: LegacyWebService) {
        ukiBasedWebService.sendRequest(to: "/1/country/get",
                                       using: .post,
                                       params: [:],
                                       contentFormat: .json,
                                       needsAuthentication: false,
                                       responseParser: CountryResponse()) { result in
            if case let .success(country) = result {
                self.userCountry = country
            }
                    }
    }

    struct CountryResponse: ResponseParserProtocol {
        func parse(data: Data) throws -> UserCountry {
            return try JSONDecoder().decode(DashlaneResponse<UserCountry>.self, from: data).content
        }
    }
}
