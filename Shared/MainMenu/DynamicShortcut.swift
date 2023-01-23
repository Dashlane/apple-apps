import Foundation
import UIKit

struct ShortcutAction: Hashable {

    let shortcut: DynamicShortcut
    let action: () -> Void

    public func hash(into hasher: inout Hasher) {
        hasher.combine(shortcut)
    }

    static func == (lhs: ShortcutAction, rhs: ShortcutAction) -> Bool {
        lhs.shortcut == rhs.shortcut
    }
}

enum ShortcutMenu {
    case edit
    case view

    init(menuIdentifier: UIMenu.Identifier) {
        switch menuIdentifier {
        case .edit: self = .edit
        case .view: self = .view
        default: self = .view
        }
    }

    var identifier: UIMenu.Identifier {
        switch self {
        case .edit: return .edit
        case .view: return .view
        }
    }
}

public struct DynamicShortcut: Hashable {

    let title: String
    let input: String
    let modifier: UIKeyModifierFlags
    let triggerIdentifier: String
    let menu: ShortcutMenu
    let id = UUID().uuidString

    init(title: String, input: String, modifier: UIKeyModifierFlags, menu: ShortcutMenu) {
        self.title = title
        self.input = input
        self.modifier = modifier
        self.triggerIdentifier = "\(input)-\(modifier.rawValue)"
        self.menu = menu
    }

    var command: UIKeyCommand {
        UIKeyCommand(title: title,
                     image: nil,
                     action: #selector(DashlaneNavigationController.handleMenuBarShortcut(_:)),
                     input: input,
                     modifierFlags: modifier,
                     propertyList: [triggerIdentifier: title])
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(triggerIdentifier)
    }

    public static func == (lhs: DynamicShortcut, rhs: DynamicShortcut) -> Bool {
        lhs.triggerIdentifier == rhs.triggerIdentifier
    }
}

extension DynamicShortcut {
    static var search: DynamicShortcut {
        .init(title: L10n.Localizable.keyboardShortcutSearch,
              input: "F",
              modifier: .command,
              menu: .view)
    }

    static func copyPrimary(title: String) -> DynamicShortcut {
        .init(title: title,
              input: "C",
              modifier: .command,
              menu: .edit)
    }

    static func copySecondary(title: String) -> DynamicShortcut {
        .init(title: title,
              input: "C",
              modifier: [.command, .shift],
              menu: .edit)
    }

    static var delete: DynamicShortcut {
        .init(title: L10n.Localizable.kwDelete,
              input: "\u{8}", 
              modifier: .command,
              menu: .edit)
    }

    static var edit: DynamicShortcut {
        .init(title: L10n.Localizable.kwEdit,
              input: "E",
              modifier: .command,
              menu: .edit)
    }

    static var save: DynamicShortcut {
        .init(title: L10n.Localizable.kwSave,
              input: "S",
              modifier: .command,
              menu: .edit)
    }

    static var cancel: DynamicShortcut {
        .init(title: L10n.Localizable.cancel,
              input: "\u{1B}", 
              modifier: .command,
              menu: .edit)
    }

    static var back: DynamicShortcut {
        .init(title: L10n.Localizable.kwBack,
              input: "\u{1B}", 
              modifier: .command,
              menu: .view)
    }
}
