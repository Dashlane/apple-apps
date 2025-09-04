import Combine
import CoreMainMenu
import Foundation
import SwiftTreats
import UIKit

enum ApplicationDefaultShortcutCommand: String, ShortcutCommand {
  case help
}

class ApplicationMainMenuHandler: MainMenuHandler {

  private var cancellable: AnyCancellable?

  init() {
    guard Device.is(.pad, .mac, .vision) else { return }
    load()
    UIMenuSystem.main.setNeedsRebuild()
    DispatchQueue.main.async {
      GlobalMenuHandler.shared.register(self)
    }
  }

  func update(_ builder: UIMenuBuilder) {
    UIMenu.Identifier.menusToRemove.forEach { builder.remove(menu: $0) }
    builder.replaceChildren(ofMenu: .edit, from: { _ in [] })
    builder.replaceChildren(ofMenu: .help) { _ in
      return [UIKeyCommand.helpItem]
    }
  }

  private func handle(_ command: ApplicationDefaultShortcutCommand) {
    switch command {
    case .help:
      let url = URL(string: "_")!
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }

  func handle(_ command: UICommand) -> Bool {
    guard let command = ApplicationDefaultShortcutCommand(fromPropertyList: command.propertyList)
    else {
      return false
    }
    handle(command)
    return true
  }

  func load() {
    cancellable = UIApplication.menubarPublisher.sink { [weak self] builder in
      self?.update(builder)
    }
  }

  func unload() {
    cancellable?.cancel()
  }
}

extension UIMenu.Identifier {
  fileprivate static var menusToRemove: [UIMenu.Identifier] {
    [
      .format,
      .font,
    ]
  }
}

extension UIKeyCommand {
  fileprivate static var helpItem: UIKeyCommand {
    UIKeyCommand(
      title: L10n.Localizable.keyboardShortcutDashlaneHelp,
      image: nil,
      action: #selector(MainMenuHandlerNavigationController.handleMenuBarShortcut(_:)),
      input: "?",
      modifierFlags: .command,
      propertyList: ApplicationDefaultShortcutCommand.help.propertyList)
  }
}
