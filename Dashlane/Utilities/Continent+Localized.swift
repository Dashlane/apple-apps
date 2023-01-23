import Foundation
import CoreRegion

extension Continent {

    var localized: String {
        let keysForContinent: [String: String] = [
                        "AN": "CONTINENT_ANTARTICA",
                        "SA": "CONTINENT_SOUTH_AMERICA",
                        "AF": "CONTINENT_AFRICA",
                        "AS": "CONTINENT_ASIA",
                        "OC": "CONTINENT_OCEANIA",
                        "EU": "CONTINENT_EUROPE",
                        "NA": "CONTINENT_NORTH_AMERICA"
        ]

        return NSLocalizedString(keysForContinent[self.code] ?? "", comment: "")
    }
}
