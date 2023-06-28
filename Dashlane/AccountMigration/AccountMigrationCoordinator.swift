import Foundation
import CoreSession
import DashTypes
import CorePersonalData
import Combine
import AuthenticationServices
import CorePremium
import CoreUserTracking
import DashlaneCrypto
import SwiftTreats
import CoreSync
import LoginKit
import UIComponents
import CoreLocalization

class AccountMigrationCoordinator: NSObject, Coordinator, SubcoordinatorOwner {

    enum Completion {
        case cancel
        case finished(Session)
    }

    var subcoordinator: Coordinator?
    let sessionServices: SessionServicesContainer
    let completion: (Result<Completion, Error>) -> Void
    private var accountCryptoChangerService: AccountCryptoChangerService?
    let authTicket: String?
    let navigator: Navigator
    private let type: MigrationType
    private let mpNavigator: DashlaneNavigationController
    let logger: Logger

    init(type: MigrationType,
         navigator: Navigator,
         sessionServices: SessionServicesContainer,
         authTicket: String?,
         logger: Logger,
         completion: @escaping (Result<Completion, Error>) -> Void) {
        self.sessionServices = sessionServices
        self.authTicket = authTicket
        self.completion = completion
        self.navigator = navigator
        self.type = type
        self.logger = logger
        self.mpNavigator = DashlaneNavigationController()
    }

    func start() {
        switch type {
        case let .masterPasswordToRemoteKey(validator):
            navigator.push(makeMPToSSOMigrationView(validator: validator), animated: true)
        case let .remoteKeyToMasterPassword(validator):
            navigator.push(makeSSOToMPMigrationView(validator: validator), animated: true)
        case .masterPasswordToMasterPassword:
            startMasterPasswordToMasterPassword()
        }
    }

    private func startMasterPasswordToMasterPassword() {
        let premiumStatusService = PremiumStatusService(webservice: sessionServices.legacyWebService)
        premiumStatusService.getStatus { (result) in
            DispatchQueue.main.async {
                switch result {
                case let .success((premiumStatus, _)):
                    let isSyncEnabled = premiumStatus.capabilities.sync.enabled
                    self.mpNavigator.setRootNavigation(self.makeMPToMPMigrationView(navigator: self.mpNavigator,
                                                                                    title: isSyncEnabled ? L10n.Localizable.changeMasterPasswordWarningPremiumTitle : L10n.Localizable.changeMasterPasswordWarningFreeDescription,
                                                                                    subtitle: isSyncEnabled ? L10n.Localizable.changeMasterPasswordWarningPremiumDescription : L10n.Localizable.changeMasterPasswordWarningFreeTitle))
                    self.mpNavigator.modalPresentationStyle = .overFullScreen
                    self.mpNavigator.navigationBar.applyStyle(.default())
                    self.navigator.present(self.mpNavigator, animated: true, completion: {

                    })
                case .failure(let error):
                    self.showError {
                        self.navigator.dismiss(animated: true)
                        self.completion(.failure(error))
                    }
                }
            }
        }
    }

    private func makeMPToSSOMigrationView(validator: SSOValidator) -> SSOMigrationView {
        return SSOMigrationView { [self] result in
            switch result {
            case .cancel:
                self.navigator.dismiss(animated: true)
                self.completion(.success(.cancel))
            case .migrate:
                showSSOLogin(with: validator)
            }
        }
    }

    private func makeSSOToMPMigrationView(validator: SSOValidator) -> MasterPasswordMigrationView {
        let view = MasterPasswordMigrationView(title: L10n.Localizable.ssoToMPTitle,
                                               subtitle: L10n.Localizable.ssoToMPSubtitle,
                                               migrateButtonTitle: L10n.Localizable.ssoToMPButton,
                                               cancelButtonTitle: CoreLocalization.L10n.Core.kwLogOut) { result in
            switch result {
            case .cancel:
                self.navigator.dismiss(animated: true)
                self.completion(.success(.cancel))
            case .migrate:
                if let authTicket = self.authTicket {
                    self.showMasterPasswordCreationView(navigator: self.navigator, authTicket: authTicket, type: .ssoToMasterPassword)
                } else {
                    self.authenticate(with: validator) { result in
                        switch result {
                        case let .success((authTicket, _)):
                            DispatchQueue.main.async {
                                self.showMasterPasswordCreationView(navigator: self.navigator, authTicket: authTicket, type: .ssoToMasterPassword)
                            }
                        case let .failure(error):
                            self.completion(.failure(error))
                        }
                    }
                }
            }
        }
        return view
    }

    private func makeMPToMPMigrationView(navigator: Navigator, title: String, subtitle: String) -> MasterPasswordMigrationView {
        let view = MasterPasswordMigrationView(title: title,
                                               subtitle: subtitle,
                                               migrateButtonTitle: L10n.Localizable.changeMasterPasswordWarningContinue,
                                               cancelButtonTitle: L10n.Localizable.changeMasterPasswordWarningCancel) { result in
            switch result {
            case .cancel:
                self.sessionServices.activityReporter.report(UserEvent.ChangeMasterPassword(flowStep: .cancel))
                self.navigator.dismiss(animated: true)
                self.completion(.success(.cancel))
            case .migrate:
                self.sessionServices.activityReporter.report(UserEvent.ChangeMasterPassword(flowStep: .start))
                self.showMasterPasswordCreationView(navigator: navigator, authTicket: nil, type: .masterPasswordToMasterPassword)
            }
        }
        return view
    }

    private func showMasterPasswordCreationView(navigator: Navigator, authTicket: String?, type: AccountMigrationType) {
        let model = NewMasterPasswordViewModel(mode: .masterPasswordChange,
                                               evaluator: sessionServices.appServices.passwordEvaluator,
                                               keychainService: sessionServices.appServices.keychainService,
                                               login: sessionServices.session.login,
                                               activityReporter: sessionServices.activityReporter) { [weak self] result in
            switch result {
            case .back:
                self?.sessionServices.activityReporter.report(UserEvent.ChangeMasterPassword(flowStep: .cancel))
                self?.navigator.dismiss(animated: true)
            case let .next(masterPassword: masterPassword):
                Task {
                    await self?.startChangingMasterPassword(with: masterPassword,
                                                      navigator: navigator, authTicket: authTicket,
                                                      type: type)
                }
            }
        }
        let masterPasswordCreationView = NewMasterPasswordView(model: model, title: "")
        navigator.push(masterPasswordCreationView)
    }

    private func startChangingMasterPassword(with masterPassword: String,
                                             navigator: Navigator,
                                             authTicket: String?,
                                             type: AccountMigrationType) async {

        var newAuthTicket: CoreSync.AuthTicket?
        if let authTicket = authTicket, type == .ssoToMasterPassword {
            newAuthTicket = AuthTicket(token: authTicket, verification: Verification(type: .email_token))
        }
        do {
            self.accountCryptoChangerService = try await createMasterPasswordChangerService(withNewMasterPassword: masterPassword,
                                                                                            sessionServices: sessionServices,
                                                                                            newVerification: type == .ssoToMasterPassword ? Verification(type: .email_token) : nil,
                                                                                            authTicket: newAuthTicket,
                                                                                            type: type)
            let model = sessionServices.viewModelFactory.makeMigrationProgressViewModel(
                type: self.type,
                accountCryptoChangerService: accountCryptoChangerService!,
                context: .accountTypeMigration) { [weak self] result in
                    guard let self = self else {
                        return
                    }

                    switch result {
                    case let .success(session):
                        self.completion(.success(.finished(session)))
                    case let .failure( error):
                        self.completion(.failure(error))
                    }
                }
            navigator.push(MigrationProgressView(model: model))
            self.accountCryptoChangerService?.start()

        } catch {
            self.completion(.failure(error))
        }
    }

    func startChangeMasterKey(withAuthTicket authTicket: String, serviceProviderKey: String) {
        do {

            accountCryptoChangerService = try self.createMasterPasswordChangerService(withServiceProviderKey: serviceProviderKey,
                                                                                     sessionServices: self.sessionServices,
                                                                                      authTicket: authTicket)
            let model = sessionServices.viewModelFactory.makeMigrationProgressViewModel(
                type: self.type,
                accountCryptoChangerService: accountCryptoChangerService!,
                context: .accountTypeMigration) { result in
                    switch result {
                    case let .success(session):
                        self.completion(.success(.finished(session)))
                    case .failure(let error):
                        self.completion(.failure(error))
                    }
                }
            navigator.push(MigrationProgressView(model: model))
            accountCryptoChangerService?.start()
        } catch {
            self.completion(.failure(error))
        }
    }

    private func showError(completion: @escaping () -> Void) {
        let title = L10n.Localizable.changeMasterPasswordWarningPremiumStatusUpdateErrorTitle
        let message = L10n.Localizable.changeMasterPasswordWarningPremiumStatusUpdateErrorDescription
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction.init(title: CoreLocalization.L10n.Core.kwButtonOk, style: .default, handler: {_ in completion()}))
        DispatchQueue.main.async {
            self.navigator.present(alert, animated: true)
        }
    }
}

extension AccountMigrationCoordinator: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        #if canImport(UIKit)
        UIApplication.shared.keyUIWindow ?? ASPresentationAnchor()
        #else
        ASPresentationAnchor()
        #endif
    }
}
