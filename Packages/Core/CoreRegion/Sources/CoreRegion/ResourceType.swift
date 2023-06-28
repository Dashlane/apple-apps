import Foundation

public enum ResourceType {
    case banks
    case geographicalStates
    case callingCodes
    case continents
    case europeanUnionCountries

    var resourceName: String {
        switch self {
        case .banks:
            return "banks"
        case .geographicalStates:
            return "geographicalStates"
        case .callingCodes:
            return "callingCodes"
        case .continents:
            return "continents"
        case .europeanUnionCountries:
            return "europeanUnionCountries"
        }
    }
    var resourceExtension: String { return "json" }

    func loadResource() throws -> Data {
        let url = Bundle.module.url(forResource: resourceName,
                             withExtension: resourceExtension)!
        return try Data(contentsOf: url)
    }
}
