import CoreTypes
import Foundation
import SwiftUI
import UIKit
import UserTrackingFoundation

extension UINavigationController: Navigator {
  public func dismiss(animated: Bool) {
    dismiss(animated: animated, completion: nil)
  }

  public func pop(animated: Bool) {
    popViewController(animated: animated)
  }

  public func push<Content>(_ view: Content, animated: Bool) where Content: View {
    let controller = makeContentViewController(for: view)
    pushViewController(controller, animated: animated)
  }

  public func setRootNavigation<Content: View>(_ view: Content, animated: Bool) {
    let controller = makeContentViewController(for: view)
    setViewControllers([controller], animated: animated)
  }

  @discardableResult
  public func present<Content: View>(
    _ view: Content, presentationStyle: UIModalPresentationStyle = .automatic, animated: Bool
  ) -> UINavigationController {
    let controller = makeContentViewController(for: view)
    return presentAsModal(controller, style: presentationStyle, animated: animated)
  }

  public func present<Content: View>(
    _ view: Content, presentationStyle: UIModalPresentationStyle = .automatic, animated: Bool
  ) {
    let controller = makeContentViewController(for: view)
    controller.modalPresentationStyle = presentationStyle
    self.present(
      controller, animated: true,
      completion: {

      })
  }

  private func makeContentViewController<Content: View>(for view: Content) -> UIViewController {
    return UIHostingController(rootView: view.dashlaneDefaultStyle())
  }

  @discardableResult
  private func presentAsModal(
    _ viewController: UIViewController, style: UIModalPresentationStyle, animated: Bool
  ) -> UINavigationController {

    let navigationController = UINavigationController()
    navigationController.pushViewController(viewController, animated: animated)
    viewController.modalPresentationStyle = .overFullScreen
    navigationController.modalPresentationStyle = style
    self.present(
      navigationController, animated: true,
      completion: {

      })
    return navigationController
  }
}

extension View {
  func dashlaneDefaultStyle() -> some View {
    self.tint(.ds.accentColor)
  }
}
