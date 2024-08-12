import Foundation

enum XMLKeyCase {
  static var `default`: XMLKeyCase {
    return .capitalizedFirstLetter
  }

  case capitalizedFirstLetter
  case lowercasedFirstLetter
}

extension XMLRuleException {
  var keyCase: XMLKeyCase {
    switch self {
    case .skip, .keepSpecUndefinedKey:
      return .`default`
    case .lowerCasedKey(let current, _):
      return current ? .lowercasedFirstLetter : .`default`
    }
  }

  var childKeyCase: XMLKeyCase {
    switch self {
    case .skip, .keepSpecUndefinedKey:
      return .`default`
    case .lowerCasedKey(_, let child):
      return child ? .lowercasedFirstLetter : .`default`
    }
  }
}

extension String {
  func applying(_ keyCase: XMLKeyCase) -> String {
    switch keyCase {
    case .capitalizedFirstLetter:
      return self.capitalizingFirstLetter()
    case .lowercasedFirstLetter:
      return self
    }
  }
}
