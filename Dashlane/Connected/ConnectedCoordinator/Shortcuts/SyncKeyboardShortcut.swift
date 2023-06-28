import Foundation
import Combine
import UIKit
import DashlaneAppKit
import UIComponents

class SyncKeyboardShortcut {

    private let syncService: SyncService
    private var isSyncing: Bool
    private var lastSync: Date

    private var cancellables = Set<AnyCancellable>()

    private let formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    init(syncService: SyncService, refreshMenuBar: PassthroughSubject<Void, Never>) {
        self.syncService = syncService
        self.isSyncing = syncService.syncStatus.isSyncing
        self.lastSync = syncService.lastTimeSyncTriggered
        syncService.$syncStatus.combineLatest(syncService.$lastTimeSyncTriggered)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (status, timestamp) in
                self?.change(to: status, lastSync: timestamp)
                refreshMenuBar.send()
            }.store(in: &cancellables)
    }

    private func change(to status: SyncService.SyncStatus, lastSync: Date) {
        self.isSyncing = status.isSyncing
        self.lastSync = lastSync
    }

    func sync() {
        syncService.sync(triggeredBy: .manual)
    }

    func commands() -> [UICommand] {
        [
            UIKeyCommand.makeSyncInfoItem(isSyncing: isSyncing, lastSync: lastSync, formatter: formatter),
            UIKeyCommand.makeSyncItem(enable: !isSyncing)
        ]
    }
}

private extension UIKeyCommand {

    static func makeSyncInfoItem(isSyncing: Bool, lastSync: Date, formatter: DateFormatter) -> UICommand {
        let title: String
        if isSyncing {
            title = L10n.Localizable.keyboardShortcutSyncing
        } else {
            let lastSyncTitle = formatter.string(from: lastSync)
            title = L10n.Localizable.keyboardShortcutLastSync(lastSyncTitle)
        }
        return UICommand(title: title, action: #selector(UIKeyCommand.emptyFunction))
    }

            @objc func emptyFunction() { }

    static func makeSyncItem(enable: Bool) -> UIKeyCommand {
        let selector: Selector
        if enable {
            selector = #selector(DashlaneNavigationController.handleMenuBarShortcut(_:))
        } else {
            selector = #selector(UIKeyCommand.emptyFunction)
        }
        return UIKeyCommand(title: L10n.Localizable.keyboardShortcutSyncNow,
                     image: nil,
                     action: selector,
                     input: "R",
                     modifierFlags: .command,
                     propertyList: SessionDefaultShortcutCommand.sync.propertyList)
    }
}

private extension SyncService.SyncStatus {
    var isSyncing: Bool {
        switch self {
        case .syncing: return true
        default: return false
        }
    }
}
