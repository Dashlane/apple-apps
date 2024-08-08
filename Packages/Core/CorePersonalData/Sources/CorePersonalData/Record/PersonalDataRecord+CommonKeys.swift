import Foundation

extension PersonalDataRecord {
  public enum CommonKey: String {
    case id
    case title
    case spaceId
    case objectId
  }

  public subscript(key: CommonKey) -> String? {
    get {
      content[key]
    }
    set {
      content[key] = newValue
    }
  }
}

extension PersonalDataCollection {
  public subscript(key: PersonalDataRecord.CommonKey) -> String? {
    get {
      self[key.rawValue]?.item
    }
    set {
      self[key.rawValue] = newValue.map { .item($0) }
    }
  }
}
