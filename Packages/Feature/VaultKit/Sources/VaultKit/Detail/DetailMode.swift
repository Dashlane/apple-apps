import SwiftUI

public enum DetailMode: Hashable {
  case viewing
  case limitedViewing
  case updating
  case adding(prefilled: Bool = false)
}

extension DetailMode {
  public var isEditing: Bool {
    switch self {
    case .viewing, .limitedViewing:
      false
    case .updating, .adding:
      true
    }
  }

  public var isAdding: Bool {
    switch self {
    case .adding:
      return true
    default:
      return false
    }
  }

  public var isAddingPrefilled: Bool {
    switch self {
    case .adding(true):
      return true
    default:
      return false
    }
  }

}

public struct DetailModeEnvironmentKey: EnvironmentKey {
  public static var defaultValue: DetailMode = .viewing
}

extension EnvironmentValues {
  public var detailMode: DetailMode {
    get {
      return self[DetailModeEnvironmentKey.self]
    }
    set {
      self[DetailModeEnvironmentKey.self] = newValue
    }
  }
}
