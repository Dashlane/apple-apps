import Foundation
import SwiftTreats

public indirect enum PersonalDataValue: Codable, Hashable {

  case item(String)
  case list(PersonalDataList)
  case collection(PersonalDataCollection)
  case object(PersonalDataObject)
}

public typealias PersonalDataCollection = [String: PersonalDataValue]

public typealias PersonalDataList = [PersonalDataValue]

public struct PersonalDataObject: Codable, Hashable {
  @RawRepresented
  public var type: XMLDataType?
  public var content: PersonalDataCollection
  var id: String? {
    if type == .settings {
      return Settings.id.rawValue
    } else {
      return content["id"]?.item
    }
  }
}

extension PersonalDataValue: CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
    case let .item(value):
      return value.debugDescription
    case let .list(value):
      return value.debugDescription
    case let .collection(value):
      return value.debugDescription
    case let .object(object):
      return String(describing: object)
    }
  }
}
