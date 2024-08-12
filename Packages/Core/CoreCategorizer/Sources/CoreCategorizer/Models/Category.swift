import Foundation

public struct Category {
  public let id: String
  public let color: CommonColor
  public let code: String

  public let important: Bool
}

internal struct Domain {
  public let domain: String
}

extension Category: Equatable, Hashable {
  public static func == (lhs: Category, rhs: Category) -> Bool {
    return lhs.id == rhs.id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension Category {

  private struct DBKeys {
    static let color = "COLOR"
    static let code = "CODE"
    static let id = "ID"
    static let important = "IMPORTANT"
  }

  init?(row: SQLRow) {
    guard let uiColor = row[DBKeys.color].flatMap(CommonColor.init),
      let code = row[DBKeys.code],
      let id = row[DBKeys.id]
    else {
      return nil
    }
    self.init(id: id, color: uiColor, code: code, important: row[DBKeys.important] == "1")
  }
}

extension Domain {
  init?(row: SQLRow) {
    guard let domain = row["DOMAIN"] else { return nil }
    self.init(domain: domain)
  }
}
