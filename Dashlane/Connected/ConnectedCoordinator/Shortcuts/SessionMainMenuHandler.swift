import Foundation
import UIKit
import Combine
import DashTypes
import DashlaneAppKit
import SwiftTreats
import UIComponents

enum SessionDefaultShortcutCommand: String, ShortcutCommand {
    case sync
}

class SessionMainMenuHandler: MainMenuHandler {

    private let applicationHandler: ApplicationMainMenuHandler
    @Published
    private var dynamicShortcuts = Set<ShortcutAction>()

    private let syncKeyboardShortcut: SyncKeyboardShortcut
    private let menuBuilder: SessionMainMenuBuilder
    private let menuSystemPublisher: PassthroughSubject<Void, Never>

    private var cancellables = Set<AnyCancellable>()

    init(applicationHandler: ApplicationMainMenuHandler, syncService: SyncService, bridge: MainMenuBarBridge, logger: Logger) {
        self.applicationHandler = applicationHandler
        applicationHandler.unload()
        menuSystemPublisher = PassthroughSubject<Void, Never>()
        syncKeyboardShortcut = SyncKeyboardShortcut(syncService: syncService, refreshMenuBar: menuSystemPublisher)
        menuBuilder = .init(syncShortcut: syncKeyboardShortcut, logger: logger)
        guard Device.isIpadOrMac else { return }

        bridge.$dynamicShortcuts.sink {
            self.dynamicShortcuts = $0
        }.store(in: &cancellables)

        $dynamicShortcuts
            .sink { [weak self] _ in
                self?.menuSystemPublisher.send()
            }.store(in: &cancellables)

        menuSystemPublisher
            .throttle(for: .milliseconds(250), scheduler: RunLoop.main, latest: false)
            .sink { _ in
                UIMenuSystem.main.setNeedsRebuild()
            }.store(in: &cancellables)

        menuSystemPublisher.send()
        DispatchQueue.main.async {
            GlobalMenuHandler.shared.register(self)
        }
    }

    func unload() {
        cancellables.forEach({ $0.cancel() })
        GlobalMenuHandler.shared.unregister(self)
        applicationHandler.load()

    }

    func update(_ builder: UIMenuBuilder) {
        menuBuilder.update(builder, dynamicShortcuts: dynamicShortcuts)
    }

    func handle(_ command: UICommand) -> Bool {
        if let authenticatedCommand = SessionDefaultShortcutCommand(fromPropertyList: command.propertyList) {
            handle(authenticatedCommand)
            return true
        } else if let dynamicShortcut = dynamicShortcut(fromPropertyList: command.propertyList) {
            handle(dynamicShortcut)
            return true
        }
        return false
    }

    func handle(_ command: SessionDefaultShortcutCommand) {
        switch command {
        case .sync:
            syncKeyboardShortcut.sync()
        }
    }

    func handle(_ shortcut: DynamicShortcut) {
        guard let dynamicShortcut = dynamicShortcuts.first(where: { $0.shortcut == shortcut }) else {
            fatalError("There should be an action for a shortcut to be called")
        }
        dynamicShortcut.action()
    }

    private func dynamicShortcut(fromPropertyList propertyList: Any?) -> DynamicShortcut? {
        guard let dictionary = propertyList as? [String: String], let id = dictionary.first?.key else {
            return nil
        }
        return dynamicShortcuts.first(where: { $0.shortcut.triggerIdentifier == id })?.shortcut
    }
}
