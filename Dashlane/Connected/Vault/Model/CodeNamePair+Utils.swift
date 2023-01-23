import Foundation
import CorePersonalData
import CoreRegion
import DashTypes

extension CountryCodeNamePair {
    static var defaultCountry: CountryCodeNamePair {
        let code = System.country
        guard let name = Locale.current.localizedString(forRegionCode: code) else {
            return CountryCodeNamePair(code: code, name: "")
        }
        return CountryCodeNamePair(code: code, name: name)
    }
}
