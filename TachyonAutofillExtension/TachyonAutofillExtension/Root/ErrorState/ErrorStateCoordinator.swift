import Foundation
import UIKit
import DashTypes
import LocalAuthentication
import SwiftTreats
import DashlaneAppKit

class ErrorStateCoordinator: Coordinator, SubcoordinatorOwner {
    
    unowned var rootNavigationController: DashlaneNavigationController
    let error: ErrorStateCoordinator.SupportedError
    let completion: Completion<Void>
    var subcoordinator: Coordinator?
    let tachyonLogger: TachyonLogger?
    
    enum SupportedError: Error {
        case noUserConnected(details: String)
        case ssoUserWithNoConvenientLoginMethod
        
        var canAuthenticateUsingBiometrics: Bool {
            let context = LAContext()
            return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        }
        
        var title: String {
            switch self {
            case .noUserConnected:
                return NSLocalizedString("TachyonLoginRequiredScreenDescription", comment: "")
            case .ssoUserWithNoConvenientLoginMethod:
                if canAuthenticateUsingBiometrics {
                    return String(format: NSLocalizedString("ssoUseBiometricsContent", comment: ""), Device.currentBiometryDisplayableName)
                } else {
                    return NSLocalizedString("ssoUsePinCodeContent", comment: "")
                }
            }
        }
        
        var code: String {
            switch self {
            case let .noUserConnected(details):
                return details
            case .ssoUserWithNoConvenientLoginMethod:
                return "ConvenientMethod"
            }
        }
        
        var actionTitle: String {
            switch self {
                case .noUserConnected:
                    return NSLocalizedString("TachyonLoginRequiredScreenCTA", comment: "")
                case .ssoUserWithNoConvenientLoginMethod:
                    if canAuthenticateUsingBiometrics {
                        return NSLocalizedString("TachyonConvenientLoginMethodRequiredScreenCTA", comment: "")
                    } else {
                        return NSLocalizedString("TachyonConvenientLoginMethodRequiredScreenCTA_noBiometrics", comment: "")
                    }
            }
        }

    }
    
    init(rootNavigationController: DashlaneNavigationController,
         error: ErrorStateCoordinator.SupportedError,
         tachyonLogger: TachyonLogger?,
         completion: @escaping Completion<Void>) {
        self.rootNavigationController = rootNavigationController
        self.error = error
        self.completion = completion
        self.tachyonLogger = tachyonLogger
    }
    
    func start() {
        let input = ErrorStateViewController.Input(title: error.title, code: error.code, actionTitle: error.actionTitle)
        let errorStateViewController = StoryboardScene.TachyonInterface.errorState.instantiate(input: input)
        errorStateViewController.delegate = self
        rootNavigationController.viewControllers = [errorStateViewController]
        tachyonLogger?.log(NonAuthenticatedScreenLogEvent.displayed(reason: error.code))
    }
}

extension ErrorStateCoordinator: ErrorStateViewControllerDelegate {
    private func goToMainApp() {
        _ = openURL(URL(string: "dashlane:///")!)
        tachyonLogger?.log(NonAuthenticatedScreenLogEvent.goToMainApp)
    }
    
    private func goToSecuritySettings() {
        _ = openURL(URL(string: "dashlane:///settings/security")!)
    }
    
    func handleAction() {
        switch error {
            case .noUserConnected: goToMainApp()
            case .ssoUserWithNoConvenientLoginMethod: goToSecuritySettings()
        }
    }

    func close(_ errorStateViewController: ErrorStateViewController) {
        completion(.success)
        tachyonLogger?.log(NonAuthenticatedScreenLogEvent.cancel)
    }

    @discardableResult
    @objc func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = rootNavigationController
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }
    
}
