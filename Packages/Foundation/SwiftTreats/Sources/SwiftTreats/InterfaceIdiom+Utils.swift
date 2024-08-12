#if canImport(UIKit)
  import UIKit

  extension UIUserInterfaceIdiom {
    public var isIpadOrMac: Bool {
      switch self {
      case .mac, .pad:
        return true
      default:
        return false
      }
    }
  }
#endif
