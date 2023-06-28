import Foundation
import SwiftUI
import DashlaneAppKit
import CoreSettings
import VaultKit

class MiniBrowserCardViewModel {

    enum Completion {
        case generatedPasswordCopiedToClipboard(String)
    }

    let helpCardViewModel: MiniBrowserHelpCardViewModel
    let passwordGeneratorViewModel: MiniBrowserPasswordGeneratorCardViewModel

    private let pasteboardService: PasteboardService
    private let completion: (Completion) -> Void

    init(email: String, password: String, domain: String, userSettings: UserSettings, completion: @escaping (Completion) -> Void) {
        self.helpCardViewModel = MiniBrowserHelpCardViewModel(email: email, password: password, domain: domain)
        self.passwordGeneratorViewModel = MiniBrowserPasswordGeneratorCardViewModel()
        self.pasteboardService = PasteboardService(userSettings: userSettings)
        self.completion = completion
    }

    func copyEmail(email: String) {
        pasteboardService.set(email)
    }

    func copyPassword(password: String) {
        pasteboardService.set(password)
    }

    func copyGeneratedPassword(password: String) {
        pasteboardService.set(password)
        completion(.generatedPasswordCopiedToClipboard(password))
    }
}
