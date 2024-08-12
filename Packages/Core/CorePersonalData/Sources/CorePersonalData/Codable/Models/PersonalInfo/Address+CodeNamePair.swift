import Foundation

public struct CountryCodeNamePair: CodeNamePair, Identifiable, Codable, Hashable {
  public var id: String {
    return self.code
  }

  public static let codeFormat: CodeFormat = .country
  public let code: String
  public let name: String
  public init(code: String, name: String) {
    self.code = code
    self.name = name
  }

  public static var systemCountryCode: CountryCodeNamePair? {
    guard let regionCode = Locale.current.language.region?.identifier,
      let name = Locale.current.localizedString(forRegionCode: regionCode)
    else {
      return nil
    }
    return CountryCodeNamePair(code: regionCode, name: name)
  }
}

public struct StateCodeNamePair: CodeNamePair, Identifiable, Codable, Hashable {
  public var id: String {
    code
  }

  public static let level = "0"
  public static let codeFormat: CodeFormat = .state
  public let code: String
  public let name: String

  public init(code: String, name: String) {
    self.code = code
    self.name = name
  }

  public init(components: RegionCodeComponentsInfo, name: String) {
    self.code = components.countryCode + "-" + StateCodeNamePair.level + "-" + components.subcode
    self.name = name
  }
}
