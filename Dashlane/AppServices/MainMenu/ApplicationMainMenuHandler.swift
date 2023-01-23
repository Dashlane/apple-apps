import Foundation
import UIKit
import Combine
import DashlaneAppKit
import SwiftTreats

enum ApplicationDefaultShortcutCommand: String, ShortcutCommand {
    case help
}

class ApplicationMainMenuHandler: MainMenuHandler {

    private var cancellable: AnyCancellable?

    init() {
        guard Device.isIpadOrMac else { return }
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
        guard let command = ApplicationDefaultShortcutCommand(fromPropertyList: command.propertyList) else {
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

private extension UIMenu.Identifier {
    static var menusToRemove: [UIMenu.Identifier] {
        [
            .format,
            .font
        ]
    }
}

private extension UIKeyCommand {
    static var helpItem: UIKeyCommand {
        UIKeyCommand(title: L10n.Localizable.keyboardShortcutDashlaneHelp,
                     image: nil,
                     action: #selector(DashlaneNavigationController.handleMenuBarShortcut(_:)),
                     input: "?",
                     modifierFlags: .command,
                     propertyList: ApplicationDefaultShortcutCommand.help.propertyList)
    }
}
