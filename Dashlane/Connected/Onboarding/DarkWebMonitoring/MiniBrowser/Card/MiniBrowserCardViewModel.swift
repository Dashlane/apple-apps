import Foundation
import SwiftUI
import DashlaneAppKit
import CoreSettings

class MiniBrowserCardViewModel {

    enum Completion {
        case generatedPasswordCopiedToClipboard(String)
    }

    let helpCardViewModel: MiniBrowserHelpCardViewModel
    let passwordGeneratorViewModel: MiniBrowserPasswordGeneratorCardViewModel

    private let usageLogService: DWMLogService
    private let pasteboardService: PasteboardService
    private let completion: (Completion) -> Void

    init(email: String, password: String, domain: String, usageLogService: DWMLogService, userSettings: UserSettings, completion: @escaping (Completion) -> Void) {
        self.usageLogService = usageLogService
        self.helpCardViewModel = MiniBrowserHelpCardViewModel(email: email, password: password, domain: domain, usageLogService: usageLogService)
        self.passwordGeneratorViewModel = MiniBrowserPasswordGeneratorCardViewModel(usageLogService: usageLogService)
        self.pasteboardService = PasteboardService(userSettings: userSettings)
        self.completion = completion
    }

    func copyEmail(email: String) {
        usageLogService.log(.emailCopied)
        pasteboardService.set(email)
    }

    func copyPassword(password: String) {
        usageLogService.log(.passwordCopied)
        pasteboardService.set(password)
    }

    func copyGeneratedPassword(password: String) {
        usageLogService.log(.generatedPasswordCopied)
        pasteboardService.set(password)
        completion(.generatedPasswordCopiedToClipboard(password))
    }
}
