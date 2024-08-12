import DashTypes
import Foundation
import UIComponents
import UIKit

struct SessionMainMenuBuilder {
  let syncShortcut: SyncKeyboardShortcut
  let logger: Logger

  func update(_ builder: UIMenuBuilder, dynamicShortcuts: Set<ShortcutAction>) {
    builder.insertSibling(makeSyncMenu(), beforeMenu: .help)

    let dynamic = makeDynamicMenus(shortcuts: dynamicShortcuts)

    if dynamic.contains(where: { $0.key == .application }) {
      builder.remove(menu: .preferences)
    }

    dynamic.forEach { item in
      builder.insertChild(item.value, atEndOfMenu: item.key.identifier)
    }
  }

  private func makeSyncMenu() -> UIMenu {
    let items = syncShortcut.commands()
    return UIMenu(
      title: L10n.Localizable.keyboardShortcutSync,
      image: nil,
      identifier: .tools,
      options: [],
      children: items)
  }

  private func makeDynamicMenus(shortcuts: Set<ShortcutAction>) -> [ShortcutMenu: UIMenu] {

    guard !shortcuts.isEmpty else { return [:] }

    return
      shortcuts
      .sorted(by: { $0.shortcut.title < $1.shortcut.title })
      .reduce(into: [ShortcutMenu: [UIKeyCommand]]()) { result, element in
        result[element.shortcut.menu, default: []].append(
          element.shortcut.command(
            selector: #selector(
              DashlaneHostingViewController<ConnectedRootView>.handleMenuBarShortcut(_:))))
      }
      .mapValues { commands in
        UIMenu(
          title: "",
          image: nil,
          identifier: nil,
          options: .displayInline,
          children: commands)
      }
  }
}

extension UIMenu.Identifier {
  fileprivate static let tools = UIMenu.Identifier("com.dashlane.fiber.tools")
}
