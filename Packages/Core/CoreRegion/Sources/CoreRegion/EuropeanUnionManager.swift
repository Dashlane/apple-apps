import Foundation

public struct EuropeanUnionManager {

    public let countries: [Country]

    public init() {
        do {
            let data = try ResourceType.europeanUnionCountries.loadResource()
            countries = try JSONDecoder().decode([Country].self, from: data)
        } catch {
            fatalError("Impossible to load Countries: \(error)")
        }
    }

    public func contains(countryCode: String) -> Bool {
        return countries.contains(Country(code: countryCode))
    }
}
