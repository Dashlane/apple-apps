import Foundation

public struct ContinentsManager {

  public let continents: [Continent]

  public init() {
    do {
      let data = try ResourceType.continents.loadResource()
      continents = try JSONDecoder().decode([Continent].self, from: data)
    } catch {
      fatalError("Impossible to load Continents: \(error)")
    }
  }

  public func getContinent(of country: Country) -> Continent? {
    return continents.first(where: {
      return $0.countries.contains(where: { $0 == country })
    })
  }
}
