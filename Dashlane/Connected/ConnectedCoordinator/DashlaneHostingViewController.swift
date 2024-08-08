import SwiftUI
import UIComponents
import UIKit

class DashlaneHostingViewController<Content: View>: UIHostingController<Content> {
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
