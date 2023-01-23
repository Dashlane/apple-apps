import Foundation
import CorePersonalData
import Combine
import DashlaneAppKit
import CoreSettings
import VaultKit

protocol ItemPasteboardProtocol {
    func copy(_ value: String, for item: VaultItem, hasSecureAccess: Bool) -> AnyPublisher<Bool, Never>
}

extension ItemPasteboardProtocol {
    func copy(_ item: VaultItem,
              valueToCopy: String,
              hasSecureAccess: Bool = false) -> AnyPublisher<Bool, Never> {
        return copy(valueToCopy, for: item, hasSecureAccess: hasSecureAccess)
    }

    func copy(_ item: CopiablePersonalData & VaultItem, hasSecureAccess: Bool = false) -> AnyPublisher<Bool, Never> {
        return copy(item.valueToCopy, for: item, hasSecureAccess: hasSecureAccess)
    }
}

struct ItemPasteboard: ItemPasteboardProtocol {
    private let accessControl: AccessControlProtocol
    private let pasteboardService: PasteboardService

    init(accessControl: AccessControlProtocol,
         userSettings: UserSettings) {
        self.accessControl = accessControl
        self.pasteboardService = PasteboardService(userSettings: userSettings)
    }

    func copy(_ value: String, for item: VaultItem, hasSecureAccess: Bool = false) -> AnyPublisher<Bool, Never> {
        guard type(of: item).requireSecureAccess && !hasSecureAccess else {
            self.updatePasteboard(with: value)
            return Just(true)
                .eraseToAnyPublisher()
        }

        return self.accessControl
            .requestAccess()
            .handleEvents(receiveOutput: { success in
                if success {
                    self.updatePasteboard(with: value)
                }
            }).eraseToAnyPublisher()
    }

    private func updatePasteboard(with value: String) {
        pasteboardService.set(value)
    }
}
