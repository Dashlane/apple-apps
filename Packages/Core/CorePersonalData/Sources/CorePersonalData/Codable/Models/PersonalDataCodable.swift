import DashTypes
import Foundation

public struct ItemValidationError: Error {
  public let invalidProperty: AnyKeyPath
}

public protocol PersonalDataCodable: Codable {
  static var contentType: PersonalDataContentType { get }

  static var xmlRuleExceptions: [String: XMLRuleException] { get }

  var metadata: RecordMetadata { get }

  var id: Identifier { get }

  func validate() throws

  mutating func prepareForSaving()
}

extension PersonalDataCodable {
  public var isSaved: Bool {
    return !metadata.id.isTemporary
  }
}

extension PersonalDataCodable {
  public static var xmlRuleExceptions: [String: XMLRuleException] {
    [:]
  }

  public func validate() throws {
  }

  public func prepareForSaving() {
  }

  public mutating func prepareForSavingAndValidate() throws {
    prepareForSaving()
    try validate()
  }

  public var isValid: Bool {
    do {
      try validate()
      return true
    } catch {
      return false
    }
  }
}
