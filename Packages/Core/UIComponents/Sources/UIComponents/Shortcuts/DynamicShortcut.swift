#if canImport(UIKit)
import CoreLocalization
import Foundation
import UIKit

public struct ShortcutAction: Hashable {
    public let shortcut: DynamicShortcut
    public let action: () -> Void

    public func hash(into hasher: inout Hasher) {
        hasher.combine(shortcut)
    }

    public static func == (lhs: ShortcutAction, rhs: ShortcutAction) -> Bool {
        lhs.shortcut == rhs.shortcut
    }
}

public enum ShortcutMenu {
    case edit
    case view
    case application

    public init(menuIdentifier: UIMenu.Identifier) {
        switch menuIdentifier {
        case .edit: self = .edit
        case .view: self = .view
        case .application: self = .application
        default: self = .view
        }
    }

    public var identifier: UIMenu.Identifier {
        switch self {
        case .edit: return .edit
        case .view: return .view
        case .application: return .application
        }
    }
}

public struct DynamicShortcut: Hashable {
    public let title: String
    public let input: String
    public let modifier: UIKeyModifierFlags
    public let triggerIdentifier: String
    public let menu: ShortcutMenu
    public let id = UUID().uuidString

    public init(title: String, input: String, modifier: UIKeyModifierFlags, menu: ShortcutMenu) {
        self.title = title
        self.input = input
        self.modifier = modifier
        self.triggerIdentifier = "\(input)-\(modifier.rawValue)"
        self.menu = menu
    }

    public func command(selector: Selector) -> UIKeyCommand {
        UIKeyCommand(title: title,
                     image: nil,
                     action: selector,
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

public extension DynamicShortcut {
    static var search: DynamicShortcut {
        .init(title: L10n.Core.keyboardShortcutSearch,
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
        .init(title: L10n.Core.kwDelete,
              input: "\u{8}", 
              modifier: .command,
              menu: .edit)
    }

    static var edit: DynamicShortcut {
        .init(title: L10n.Core.kwEdit,
              input: "E",
              modifier: .command,
              menu: .edit)
    }

    static var save: DynamicShortcut {
        .init(title: L10n.Core.kwSave,
              input: "S",
              modifier: .command,
              menu: .edit)
    }

    static var cancel: DynamicShortcut {
        .init(title: L10n.Core.cancel,
              input: "\u{1B}", 
              modifier: .command,
              menu: .edit)
    }

    static var back: DynamicShortcut {
        .init(title: L10n.Core.kwBack,
              input: "\u{1B}", 
              modifier: .command,
              menu: .view)
    }

    static var preferences: DynamicShortcut {
        .init(title: L10n.Core.kwSettings,
              input: ",",
              modifier: .command,
              menu: .application)
    }
}
#endif
