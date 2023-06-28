import Foundation
import CoreSession

final class MasterPasswordChallengeAlertViewModel: ObservableObject {
    enum Intent {
        case changeMasterPassword
        case enableMasterPasswordReset
    }

    enum Completion {
        case cancelled
        case failed
        case validated
    }

    let masterPassword: String
    let intent: Intent
    let completion: (Completion) -> Void

    init(masterPassword: String, intent: Intent, completion: @escaping (Completion) -> Void) {
        self.masterPassword = masterPassword
        self.intent = intent
        self.completion = completion
    }

        static func mock(intent: Intent) -> MasterPasswordChallengeAlertViewModel {
        .init(masterPassword: "Dashlane12", intent: intent, completion: { _ in })
    }
}
