import Foundation

public enum IconSizeType {
  case large
  case small
  case prefilledCredential

  public var size: CGSize {
    switch self {
    case .large:
      return CGSize(width: 86, height: 56)
    case .small:
      return CGSize(width: 56, height: 36)
    case .prefilledCredential:
      return CGSize(width: 70, height: 46)
    }
  }

  public var radius: CGFloat {
    switch self {
    case .large:
      return 6
    case .small:
      return 4
    case .prefilledCredential:
      return 5
    }
  }
}
