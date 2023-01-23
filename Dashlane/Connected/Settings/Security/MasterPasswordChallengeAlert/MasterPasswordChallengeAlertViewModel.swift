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

    private let session: Session

    let intent: Intent
    let completion: (Completion) -> Void

    init(session: Session, intent: Intent, completion: @escaping (Completion) -> Void) {
        self.session = session
        self.intent = intent
        self.completion = completion
    }

    var masterPassword: String? {
        session.configuration.masterKey.masterPassword
    }

        static func mock(intent: Intent) -> MasterPasswordChallengeAlertViewModel {
        .init(session: Session.mock, intent: intent, completion: { _ in })
    }
}
