import Foundation

public struct Continent: Decodable, Hashable {

  public let code: String
  public let countries: [Country]

  public init(code: String, countries: [Country]) {
    self.code = code.uppercased()
    self.countries = countries
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(code)
  }

  public static func == (lhs: Continent, rhs: Continent) -> Bool {
    return lhs.code == rhs.code
  }
}

public struct Country: Decodable, Hashable {

  public let code: String

  public init(code: String) {
    self.code = code.uppercased()
  }
}
