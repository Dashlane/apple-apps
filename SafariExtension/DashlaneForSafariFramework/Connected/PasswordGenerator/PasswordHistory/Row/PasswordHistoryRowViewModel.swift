import Foundation
import Combine
import CorePersonalData
import DashTypes
import VaultKit
import CoreLocalization

enum PasswordHistoryRowAction: MenuItem {
    case reveal
    case copy

    var menuTitle: String {
        switch self {
        case .reveal: return CoreLocalization.L10n.Core.kwReveal
        case .copy: return L10n.Localizable.kwCopyPasswordButton
        }
    }

    var canPerformAction: Bool {
        return true
    }
}

class PasswordHistoryRowViewModel: SessionServicesInjecting  {

    let generatedPassword: GeneratedPassword
    let pasteboardService: PasteboardService

    let actionsPublisher = PassthroughSubject<PasswordHistoryRowAction, Never>()

    private var cancellables = Set<AnyCancellable>()

    init(generatedPassword: GeneratedPassword, pasteboardService: PasteboardService) {
        self.generatedPassword = generatedPassword
        self.pasteboardService = pasteboardService

        actionsPublisher
            .sink(receiveValue: { [weak self] action in
                switch action {
                case .reveal:
                    break
                case .copy:
                    self?.performCopy()
                }
            })
            .store(in: &cancellables)
    }

    func performCopy() {
        if let password = generatedPassword.password {
            pasteboardService.set(password)
        }
    }
    

}
