import SwiftUI
import UIKit

public class MainMenuHandlerNavigationController: UINavigationController {
  public init() {
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("not created from storyboard")
  }

  public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    guard action == #selector(handleMenuBarShortcut(_:)) else { return false }
    return true
  }

  @objc
  public func handleMenuBarShortcut(_ sender: AnyObject) {
    guard let command = sender as? UICommand else {
      return
    }

    MainMenuBarBridge.shared.handle(command: command)
  }
}

public class MainMenuHandlerHostingViewController<Content: View>: UIHostingController<Content> {
  public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    guard action == #selector(handleMenuBarShortcut(_:)) else { return false }
    return true
  }

  @objc
  public func handleMenuBarShortcut(_ sender: AnyObject) {
    guard let command = sender as? UICommand else {
      return
    }
    MainMenuBarBridge.shared.handle(command: command)
  }

}
