import Foundation
import Combine
import UIKit
import SwiftTreats

class MainMenuBarBridge {
    static let shared = MainMenuBarBridge()

    @Published
    private(set)var dynamicShortcuts = Set<ShortcutAction>()

    private enum BatchUpdate {
        case add
        case remove
    }

    @Published
    private var updateShortcutsBatch = [BatchUpdate: [(DynamicShortcut, () -> Void)]]()

    let triggeredCommand = PassthroughSubject<UICommand, Never>()

    private var cancellables = Set<AnyCancellable>()

    let menuHandler: MainMenuHandler = GlobalMenuHandler.shared

    init() {
        guard Device.isIpadOrMac else { return }
        $updateShortcutsBatch
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
            .sink { [weak self] batch in
                self?.processBatchedUpdate(update: batch)
            }.store(in: &cancellables)
    }

    func add(_ shortcut: DynamicShortcut, action: @escaping () -> Void) {
        updateShortcutsBatch[.add, default: []].append((shortcut, action))
    }

    func remove(_ shortcut: DynamicShortcut) {
        updateShortcutsBatch[.remove, default: []].append((shortcut, {}))
    }

    func handle(command: UICommand) {
        _ = menuHandler.handle(command)
    }

    private func processBatchedUpdate(update: [BatchUpdate: [(DynamicShortcut, () -> Void)]]) {
        guard !update.isEmpty else { return }
        var shortcuts = Array(dynamicShortcuts)
        update[.remove]?.forEach({ updateElement in
            shortcuts.removeAll(where: { $0.shortcut == updateElement.0 })
        })
        update[.add]?.forEach({
            shortcuts.append(.init(shortcut: $0.0, action: $0.1))
        })
        dynamicShortcuts = Set(shortcuts.reversed())
        updateShortcutsBatch.removeAll()
    }
}
