import Foundation

public enum UnlockOriginProcess: Hashable {
  case autofillExtension(cancelAction: @MainActor () -> Void)
  case passwordApp

  var id: String {
    switch self {
    case .autofillExtension:
      return "autofillExtension"
    case .passwordApp:
      return "passwordApp"
    }
  }

  public var isExtension: Bool {
    switch self {
    case .autofillExtension: return true
    default: return false
    }
  }

  public var isPasswordApp: Bool {
    switch self {
    case .passwordApp: return true
    default: return false
    }
  }

  public static func == (lhs: UnlockOriginProcess, rhs: UnlockOriginProcess) -> Bool {
    return lhs.id == rhs.id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
