import Foundation

public enum XMLRuleException: Equatable {
  case skip

  case lowerCasedKey(current: Bool, child: Bool)

  case keepSpecUndefinedKey
}

extension XMLRuleException {
  public var isSchemaRule: Bool {
    switch self {
    case .skip:
      return false

    case .lowerCasedKey:
      return true

    case .keepSpecUndefinedKey:
      return false
    }
  }
}
