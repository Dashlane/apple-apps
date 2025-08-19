import SwiftUI
import UIDelight
import UIKit

@available(*, deprecated, message: "Prefer SwiftUI navigation")
public protocol Navigator: AnyObject {
  var topViewController: UIViewController? { get }

  func dismiss(animated: Bool)
  func pop(animated: Bool)
  func push<Content: View>(_ view: Content, animated: Bool)
  func setRootNavigation<Content: View>(_ view: Content, animated: Bool)
  func present<Content: View>(
    _ view: Content, presentationStyle: UIModalPresentationStyle, animated: Bool)
  func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
  func pushViewController(_ viewController: UIViewController, animated: Bool)
  @discardableResult
  func popToViewController(_ viewController: UIViewController, animated: Bool)
    -> [UIViewController]?
}

extension Navigator {
  public func dismiss() {
    dismiss(animated: true)
  }

  public func pop() {
    self.pop(animated: true)
  }

  public func push<Content: View>(_ view: Content) {
    self.push(view, animated: true)
  }

  public func setRootNavigation<Content: View>(_ view: Content) {
    self.setRootNavigation(view, animated: true)
  }
}
