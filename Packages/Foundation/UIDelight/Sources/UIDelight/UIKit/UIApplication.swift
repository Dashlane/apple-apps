#if canImport(UIKit)
  import UIKit

  extension UIApplication {

    public var keyUIWindow: UIWindow? {
      return UIApplication.shared.connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .first(where: { $0 is UIWindowScene })
        .flatMap({ $0 as? UIWindowScene })?.windows
        .first(where: \.isKeyWindow)
    }

    public func endEditing() {
      sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
  }
#endif
