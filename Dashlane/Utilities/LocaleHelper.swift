import Foundation

struct LocaleHelper {

    struct Country {
        let code: String
        let localizedString: String
    }

    static func countriesByCode() -> [String: Country] {

        return Locale.isoRegionCodes.compactMap({ code -> (String, Country)? in
            guard let countryName = Locale.current.localizedString(forRegionCode: code) ?? Locale(identifier: "en_US").localizedString(forRegionCode: code) else {
                return nil
            }
            return (code, Country(code: code, localizedString: countryName))
        }).reduce(into: [String: Country]()) { (result, tuple) in
            result[tuple.0] = tuple.1
        }
    }

}
