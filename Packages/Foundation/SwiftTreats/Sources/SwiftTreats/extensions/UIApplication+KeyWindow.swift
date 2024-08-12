import Foundation

#if canImport(UIKit)
  import UIKit

  extension UIApplication {
    public var keyWindowScene: UIWindowScene? {
      UIApplication.shared.connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .first(where: { $0 is UIWindowScene })
        .flatMap({ $0 as? UIWindowScene })?.windows
        .first(where: \.isKeyWindow)?.windowScene
    }
  }
#endif
