import CorePersonalData
import SwiftUI
import UIDelight
import DashlaneAppKit
import SwiftTreats

@MainActor
protocol AutoFillDemoHandler {
    func showAutofillDemo(for credential: Credential)
    func handleAutofillDemoDummyFieldsAction(_ action: AutoFillDemoDummyFields.Completion)
}

@MainActor
extension AutoFillDemoHandler {
    func autofillDemoDummyFields(
        credential: Credential,
        completion: @escaping (AutoFillDemoDummyFields.Completion) -> Void
    ) -> AutoFillDemoDummyFields {
        AutoFillDemoDummyFields(
            autoFillDomain: credential.url?.displayDomain ?? credential.title,
            autoFillEmail: credential.email,
            autoFillPassword: credential.password,
            completion: completion
        )
    }

    func showAutofillDemo(for credential: Credential, modal: @escaping () -> Void, push: @escaping () -> Void) {
        if Device.isIpadOrMac {
            modal()
        } else {
            push()
        }
    }
}

final class AutoFillDemoCoordinator: Coordinator {
    private let navigator: Navigator
    private let domain: String
    private let email: String
    private let password: String

    enum Completion {
        case back
        case setupAutofill
    }

    private let completion: (Completion) -> Void

    private var navigationController: DashlaneNavigationController?

    init(credential: Credential, navigator: Navigator, completion: @escaping (Completion) -> Void) {
        self.navigator = navigator
        self.completion = completion
        self.domain = credential.url?.displayDomain ?? credential.title
        self.email = credential.email
        self.password = credential.password
    }

    func start() {
        let autoFillDemoDummyFields = AutoFillDemoDummyFields(autoFillDomain: domain, autoFillEmail: email, autoFillPassword: password) { [weak self] result in
            switch result {
            case .back:
                self?.completion(.back)
            case .setupAutofill:
                self?.completion(.setupAutofill)
            }
        }

        if Device.isIpadOrMac {
            let viewController = UIHostingController(rootView: autoFillDemoDummyFields)
            navigationController = navigator.presentAsModal(viewController, style: .fullScreen, barStyle: .transparent, animated: true)
        } else {
            navigator.push(autoFillDemoDummyFields, animated: true)
        }
    }
}
