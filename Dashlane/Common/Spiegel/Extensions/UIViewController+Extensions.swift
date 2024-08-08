import UIKit

extension UIViewController {
  static func loadFromNib(in bundle: Bundle) -> Self {
    func instantiateFromNib<T: UIViewController>() -> T {
      return T.init(nibName: String(describing: T.self), bundle: bundle)
    }

    return instantiateFromNib()
  }
}
