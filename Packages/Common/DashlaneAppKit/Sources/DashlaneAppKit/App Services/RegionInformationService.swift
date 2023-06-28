import Foundation
import CoreRegion
import CorePersonalData

public class RegionInformationService {
    public let geoInfo: RegionInformationManager<GeographicalState>
    public let bankInfo: RegionInformationManager<Bank>
    public let europeanUnionInfo: EuropeanUnionManager
    public let callingCodes: CallingCodesInformationManager
    public let continents: ContinentsManager

    public init() throws {
        geoInfo = try RegionInformationManager<GeographicalState>()
        bankInfo = try RegionInformationManager<Bank>()
        europeanUnionInfo = EuropeanUnionManager()
        callingCodes = CallingCodesInformationManager()
        continents = ContinentsManager()
    }
}

extension RegionInformationService: CodeDecoder {
    public func decodeCode(_ code: String, for format: CodeFormat) throws -> String? {
        switch format {
        case .bank:
            guard let components = RegionCodeComponentsInfo(combinedCode: code) else {
                return nil
            }
            return bankInfo.item(for: components)?.localizedString
        case .country:
            let current = Locale.current
            return current.localizedString(forRegionCode: code)

        case .state:
            guard let components = RegionCodeComponentsInfo(combinedCode: code) else {
                return nil
            }
            return geoInfo.item(for: components, level: StateCodeNamePair.level)?.localizedString
        }
    }
}

extension RegionInformationManager {
    func item(for components: RegionCodeComponentsInfo, level: String? = nil) -> T? {
        let regions = getRegions(forCode: components.countryCode, andLevel: level)
        return regions.firstItem {  $0.code == components.subcode }
    }

    public func items(forCode code: String) -> [T] {
         return getRegions(forCode: code).first?.items ?? []
    }
}

extension Array {
    func firstItem<T: Decodable>(where predicate: (T) throws -> Bool) rethrows -> T?  where Element == RegionInformationContainer<T> {
        for region in self {
            if let state = try region.items.first(where: predicate) {
                return state
            }
        }
        return nil
    }
}

public extension CallingCodesInformationManager {
    func code(for country: CountryCodeNamePair) -> CallingCode? {
        return callingCodes.first(where: { $0.region == country.code })
    }

    func code(forCountry country: String) -> CallingCode? {
        let uppercasedCountry = country.uppercased()
        return callingCodes.first(where: { $0.region == uppercasedCountry })
    }
}
