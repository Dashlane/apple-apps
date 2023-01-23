import Foundation
import DashlaneAppKit
import CoreSettings

class ChromeImportCoordinator: Coordinator {

    private enum Step {
        case intro
        case url
        case navigationInExtension
    }

    let navigator: DashlaneNavigationController
    private let userSettings: UserSettings

    init(navigator: DashlaneNavigationController, sessionServices: SessionServicesContainer) {
        self.userSettings = sessionServices.spiegelUserSettings
        self.navigator = navigator
    }

    func start() {
        move(to: .intro)
    }

    private func move(to step: Step) {
        switch step {
        case .intro:
            showIntroScreen()
        case .url:
            showUrlScreen()
        case .navigationInExtension:
            showNavigationExtension()
        }
    }

    private func showIntroScreen() {
        let view = ChromeImportView(step: .intro, completion: { [weak self] result in
            switch result {
            case .nextStep:
                self?.move(to: .url)
            case .cancel:
                self?.navigator.pop()
            case .back, .importCompleted, .importNotYetCompleted:
                assertionFailure("Inadmissible action for this step")
            }
        })
        navigator.push(view)
    }

    private func showUrlScreen() {
        let view = ChromeImportView(step: .url, completion: { [weak self] result in
            switch result {
            case .nextStep:
                self?.move(to: .navigationInExtension)
            case .back:
                self?.navigator.pop()
            case .cancel, .importCompleted, .importNotYetCompleted:
                assertionFailure("Inadmissible action for this step")
            }
        })
        navigator.push(view)
    }

    private func showNavigationExtension() {
        let view = ChromeImportView(step: .navigationInExtension, completion: { [weak self] result in
            switch result {
            case .nextStep:
                break
            case .back:
                self?.navigator.pop()
            case .importCompleted:
                self?.importConfirmedByUser()
                self?.dismiss()
            case .importNotYetCompleted:
                break
            case .cancel:
                assertionFailure("Inadmissible action for this step")
            }
        })
        navigator.push(view)
    }

    private func importConfirmedByUser() {
        userSettings[.chromeImportDidFinishOnce] = true

                userSettings[.m2wDidFinishOnce] = true
    }

    func dismiss() {
        self.navigator.dismiss(animated: true, completion: nil)
    }

}
