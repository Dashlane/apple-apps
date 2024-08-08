import Foundation

public struct RegionInformationManager<T: RegionInformationProtocol & Decodable> {

  public typealias Regions = [RegionInformationContainer<T>]

  public let regions: Regions

  public init() throws {

    let data = try T.resourceType.loadResource()
    regions = try JSONDecoder().decode(RegionContainer<T>.self, from: data).regions
  }

  public func getRegions(forCode regionCode: String, andLevel level: String? = nil) -> Regions {
    let upperCasedRegionCode = regionCode.uppercased()
    return regions.filter {
      let regionMatches = $0.region == upperCasedRegionCode
      let levelMatches = (level == nil) || (level == $0.level)
      return regionMatches && levelMatches
    }
  }

}
