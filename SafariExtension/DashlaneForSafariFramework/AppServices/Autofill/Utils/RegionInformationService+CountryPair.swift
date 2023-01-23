import Foundation
import CoreRegion
import DashlaneAppKit
import CorePersonalData

extension RegionInformationService {
    func countryPair(forCountryName name: String) -> CountryCodeNamePair {
        let countries: [CountryCodeNamePair] = continents.countryCodes().compactMap {
            guard let country = try? decodeCode($0.code, for: .country) else { return nil }
            return CountryCodeNamePair(code: $0.code, name: country)
        }
        return countries.first(where: { $0.name == name })
            ?? CountryCodeNamePair(code: "", name: name)
    }
}

extension ContinentsManager {
    func countryCodes() -> [Country] {
        continents.flatMap { $0.countries }
    }
}
