import Foundation
import SwiftTreats

public struct PersonalDataScheme: Codable {

  public static let baseURL = "_"

  public class Property: Codable {
    public enum CodingKeys: String, CodingKey {
      case type
      case format
      case sharedField
      case triggerHistoryChange
      case deduplicationSignature
      case deprecated
      case xmlName
      case properties
      case items
      case `enum`
      case ref = "$ref"
      case embeddedJson
      case allOf
    }

    public enum ValueType: String, Codable {
      case string
      case boolean
      case integer
      case float
      case array
      case object
      case number
    }

    public enum StringFormat: String, Codable {
      case localDate = "local-date"
      case data = "base64"
      case json = "json"
      case boolean
      case month
      case year
      case country
      case bank
      case base64url = "base64url"
      case mimeType = "mime-type-accepted"
    }

    public init(type: PersonalDataScheme.Property.ValueType) {
      self.type = type
      self.items = nil
      self.xmlName = nil
      self.ref = nil
      self.format = nil
      self.embeddedJson = nil
    }

    public let xmlName: String?
    public let type: ValueType?
    public let format: StringFormat?

    @Defaulted
    public var sharedField: Bool
    @Defaulted
    public var triggerHistoryChange: Bool
    @Defaulted
    public var deduplicationSignature: Bool
    @Defaulted
    public var deprecated: Bool

    @Defaulted<[String: Property]>
    public var properties
    public let items: Property?
    @Defaulted<[String]>
    public var `enum`

    public let ref: String?
    public let embeddedJson: String?

    @Defaulted<[Property]>
    public var allOf
  }

  public let xmlName: String
  public let transactionType: String
  public let properties: [String: Property]

  @Defaulted<[Property]>
  public var allOf

  public func allProperties() throws -> [[String: PersonalDataScheme.Property]] {
    return try allOf.map { allOf -> [String: PersonalDataScheme.Property] in
      guard let ref = allOf.ref else {
        return allOf.properties
      }
      return try PersonalDataScheme.Property.makeProperty(ref: ref).properties
    } + [properties]
  }
}

extension PersonalDataScheme {
  public static func all(inSpecFolder url: URL) throws -> [PersonalDataScheme] {
    let url = url.appendingPathComponent("schemas/vault/")
    return try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
      .filter { $0.pathExtension == "json" }
      .map(PersonalDataScheme.init)
  }

  public static func allInBundle() throws -> [PersonalDataScheme] {
    try self.all(inSpecFolder: Bundle.module.resourceURL!)
  }

  public init(definitionFilename: String) throws {
    let url = Bundle.module.resourceURL!.appendingPathComponent(
      "schemas/vault/\(definitionFilename).json")
    try self.init(url: url)
  }

  public init(url: URL) throws {
    let data = try Data(contentsOf: url)
    self = try JSONDecoder().decode(PersonalDataScheme.self, from: data)
  }

}

extension PersonalDataScheme.Property {
  public static func makeProperty(ref: String) throws -> PersonalDataScheme.Property {
    if ref == "\(PersonalDataScheme.baseURL)enums/Enabled.json" {
      return PersonalDataScheme.Property(type: .boolean)
    } else {
      return try makeProperty(file: ref)
    }
  }

  static func makeProperty(file: String) throws -> PersonalDataScheme.Property {
    let file = file.replacingOccurrences(of: PersonalDataScheme.baseURL, with: "")

    let url = ["", "definitions", "embedded"].map { folder in
      Bundle.module.resourceURL!.appendingPathComponent("schemas/\(folder)/\(file)")
    }.first { url in
      FileManager.default.fileExists(atPath: url.path)
    }

    guard let url else {
      throw URLError(.unknown)
    }

    let data = try Data(contentsOf: url)

    return try JSONDecoder().decode(PersonalDataScheme.Property.self, from: data)
  }
}
