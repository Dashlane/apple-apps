import Foundation

struct LocaleHelper {

    struct Country {
        let code: String
        let localizedString: String
    }

    static func countriesByCode() -> [String: Country] {

        return Locale.Region.isoRegions.compactMap({ code -> (String, Country)? in
            guard let countryName = Locale.current.localizedString(forRegionCode: code.identifier) ?? Locale(identifier: "en_US").localizedString(forRegionCode: code.identifier) else {
                return nil
            }
            return (code.identifier, Country(code: code.identifier, localizedString: countryName))
        }).reduce(into: [String: Country]()) { (result, tuple) in
            result[tuple.0] = tuple.1
        }
    }

}
