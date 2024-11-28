#if canImport(UIKit)
  import UIKit
  import SwiftUI
  import UIDelight

  public protocol Navigator: AnyObject {
    var canDismiss: Bool { get }
    var topViewController: UIViewController? { get }

    func dismiss(animated: Bool)
    func pop(animated: Bool)
    func push<Content: View>(_ view: Content, barStyle: NavigationBarStyle, animated: Bool)
    func setRootNavigation<Content: View>(
      _ view: Content, barStyle: NavigationBarStyle, animated: Bool)
    func showDetail<Content: View>(_ view: Content, barStyle: NavigationBarStyle, animated: Bool)
    func present<Content: View>(
      _ view: Content, presentationStyle: UIModalPresentationStyle, barStyle: NavigationBarStyle,
      animated: Bool
    ) -> DashlaneNavigationController
    func present<Content: View>(
      _ view: Content, presentationStyle: UIModalPresentationStyle, animated: Bool)
    func presentAsModal(
      _ viewController: UIViewController, style: UIModalPresentationStyle,
      barStyle: NavigationBarStyle, animated: Bool
    ) -> DashlaneNavigationController
    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    func pushViewController(_ viewController: UIViewController, animated: Bool)
    func pushViewController(
      _ viewController: UIViewController, barStyle: NavigationBarStyle, animated: Bool)
    func showDetailViewController(_ viewController: UIViewController, animated: Bool)
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

    public func push<Content: View>(_ view: Content, animated: Bool = true) {
      self.push(view.dashlaneDefaultStyle(), barStyle: .default(), animated: animated)
    }

    public func push<Content: View & NavigationBarStyleProvider>(
      _ view: Content, animated: Bool = true
    ) {
      self.push(view.dashlaneDefaultStyle(), barStyle: view.navigationBarStyle, animated: animated)
    }

    public func setRootNavigation<Content: View>(
      _ view: Content, barStyle: NavigationBarStyle = .default(), animated: Bool = true
    ) {
      self.setRootNavigation(
        view.dashlaneDefaultStyle(),
        barStyle:
          barStyle, animated: animated)
    }

    public func setRootNavigation<Content: View & NavigationBarStyleProvider>(
      _ view: Content, animated: Bool = true
    ) {
      self.setRootNavigation(
        view.dashlaneDefaultStyle(), barStyle: view.navigationBarStyle, animated: animated)
    }

    public func showDetail<Content: View>(_ view: Content, animated: Bool = true) {
      self.showDetail(view.dashlaneDefaultStyle(), barStyle: .default(), animated: animated)
    }

    public func showDetail<Content: View & NavigationBarStyleProvider>(
      _ view: Content, animated: Bool = true
    ) {
      self.showDetail(
        view.dashlaneDefaultStyle(), barStyle: view.navigationBarStyle, animated: animated)
    }

    @discardableResult public func present<Content: View>(
      _ view: Content, presentationStyle: UIModalPresentationStyle = .automatic,
      barStyle: NavigationBarStyle = .default(), animated: Bool = true
    ) -> DashlaneNavigationController {
      return self.present(
        view.dashlaneDefaultStyle(), presentationStyle: presentationStyle, barStyle: barStyle,
        animated: animated)
    }

    @discardableResult public func present<Content: View & NavigationBarStyleProvider>(
      _ view: Content, presentationStyle: UIModalPresentationStyle = .automatic,
      animated: Bool = true
    ) -> DashlaneNavigationController {
      return self.present(
        view.dashlaneDefaultStyle(), presentationStyle: presentationStyle,
        barStyle: view.navigationBarStyle, animated: animated)
    }

    @discardableResult public func presentAsModal(
      _ viewController: UIViewController, animated: Bool
    ) -> Navigator {
      return self.presentAsModal(
        viewController, style: .automatic, barStyle: .default(), animated: animated)
    }

    public func present(
      _ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil
    ) {
      self.present(viewController, animated: animated, completion: completion)
    }
  }
#endif
