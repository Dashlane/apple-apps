import Foundation
import DashlaneCrypto
import DashlaneNetworking
import CoreSync
import CorePremium
import CoreSession
import UIKit
import SwiftUI

class ChangeMasterPasswordCoordinator: Coordinator {

    var navigationController: DashlaneNavigationController?
    let navigator: Navigator
    var changeMasterPasswordService: RemoteCryptoChangerService?
    let logger: MasterPasswordChangerLogger
    var changingMasterPasswordViewController: ChangingMasterPasswordViewController?
    let sessionServices: SessionServicesContainer
        var newSession: Session?

    let completion: (Result<Session, Error>) -> Void

    enum Error: Swift.Error {
        case dismissedByUser
        case changeMasterPasswordServiceError
    }

    init(navigator: Navigator,
         sessionServices: SessionServicesContainer,
         logger: MasterPasswordChangerLogger,
         completion: @escaping (Result<Session, Error>) -> Void) {
        self.navigator = navigator
        self.logger = logger
        self.completion = completion
        self.sessionServices = sessionServices
    }

    func start() {
        let warningController = makeWarningViewController()
        updateWarningMessage(in: warningController)
        self.navigationController = self.navigator.presentAsModal(warningController, style: .fullScreen, barStyle: .default, animated: true)
    }

    private func makeWarningViewController() -> ChangeMasterPasswordWarningViewController {
        let identifier = "warning"
        let storyboardName = "ChangeMasterPassword"

        let storyboard = UIStoryboard.init(name: storyboardName, bundle: .init(for: Self.self))
        guard let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? ChangeMasterPasswordWarningViewController else {
            fatalError("Impossible to retrieve ViewController")

        }
        viewController.delegate = self

        return viewController
    }

        private func pushMasterPasswordInputViewController() {
        let model = NewMasterPasswordViewModel(mode: .masterPasswordChange, evaluator: sessionServices.appServices.passwordEvaluator, logger: nil) { [weak self] result in
            switch result {
            case .back:
                self?.dismiss()
            case let .next(masterPassword: masterPassword):
                try? self?.startChangingMasterPassword(with: masterPassword)
            }
        }
        let newMasterPasswordView = NewMasterPasswordView(model: model, title: "")
        self.navigationController?.push(newMasterPasswordView)
    }

    func startChangingMasterPassword(with masterPassword: String) throws {
        changeMasterPasswordService = try createMasterPasswordChangerService(sessionServices: sessionServices, withNewMasterPassword: masterPassword)
        let changingMasterPasswordViewController = ChangingMasterPasswordViewController.instantiate(onCompletion: dismiss)
        push(viewController: changingMasterPasswordViewController)
        changeMasterPasswordService?.delegate = self
        self.changingMasterPasswordViewController = changingMasterPasswordViewController
        changeMasterPasswordService?.start()
    }

    private func updateWarningMessage(in warningController: ChangeMasterPasswordWarningViewController) {
                let updateWarning: (PremiumStatus) -> Void = { premiumStatus in
            guard let isSyncEnabled = try? premiumStatus.isSyncEnabled() else {
                assertionFailure("Sync status should be always available.")
                self.dismiss()
                return
            }

            if isSyncEnabled {
                warningController.setupForUser(with: .syncEnabled)
            } else {
                warningController.setupForUser(with: .syncDisabled)
            }
        }

                let dismissWarning = {
            warningController.showUnsuccessfulPremiumStatusUpdateError {
                self.dismiss()
            }
        }

        let premiumStatusService = PremiumStatusService(webservice: sessionServices.networkEngineV1)
        premiumStatusService.getStatus { (result) in
            switch result {
            case let .success((status, _)):
                updateWarning(status)
            case .failure:
                dismissWarning()
            }
        }
    }

            @objc func back() {
        navigationController?.popViewController(animated: true)
    }

    @objc func dismiss() {
        navigationController?.dismiss(animated: true, completion: nil)
        completion(.failure(.dismissedByUser))
    }

    func push(viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension ChangeMasterPasswordCoordinator: MasterPasswordChangerServiceDelegate {
    func didProgress(_ progression: MasterPasswordChanger.Progression) {

    }

    func didFinish(with result: Result<Void, Swift.Error>) {
        do {
            try result.get()
            logger.log(.passwordChanged)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let self = self,
                    let newSession = self.newSession else { return }

                self.changingMasterPasswordViewController?.configureViewForCompletedState {
                    self.completion(.success(newSession))
                }
            }
        } catch {
            logger.log(.failed(error: error))
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.changingMasterPasswordViewController?.configureViewForError { [weak self] in
                    self?.navigationController?.dismiss(animated: true, completion: nil)
                    self?.completion(.failure(.changeMasterPasswordServiceError))
                }
            }
        }
    }
}

extension ChangeMasterPasswordCoordinator {

    func createMasterPasswordChangerService(sessionServices: SessionServicesContainer,
                                            withNewMasterPassword newMasterPassword: String) throws -> RemoteCryptoChangerService {

        let session = sessionServices.session

        let currentCryptoKey = session.configuration.cryptoKey

        let newCryptoKey =  CryptoKey(masterKey: .masterPassword(newMasterPassword), serverKey: currentCryptoKey.serverKey)

        let newSession = try sessionServices.appServices.sessionContainer.createSession(for: newCryptoKey,
                                                                                        from: session,
                                                                                        isSSO: false,
                                                                                        isSSOToMPMigration: false)
        let masterPaswordChangerCryptoEngine = CryptoChangerEngine(current: session.masterKeyCryptoEngine, new: newSession.masterKeyCryptoEngine)
        self.newSession = newSession

        let postMPChangeUpdaterService = PostMPChangeUpdaterService(currentCryptoKey: currentCryptoKey,
                                                                    newCryptoKey: newCryptoKey,
                                                                    keychainService: sessionServices.appServices.keychainService,
                                                                    resetMasterPasswordService: sessionServices.resetMasterPasswordService,
                                                                    spiegelKeys: sessionServices.appServices.spiegelKeys,
                                                                    login: sessionServices.session.login,
                                                                    verification: nil,
                                                                    isSSO: false)

        return RemoteCryptoChangerService(syncService: sessionServices.syncService,
                                          postCryptoChangeHandler: postMPChangeUpdaterService,
                                          cryptoEngine: masterPaswordChangerCryptoEngine,
                                          apiNetworkingEngine: sessionServices.networkEngineV2,
                                          authTicket: nil,
                                          remoteKeys: nil,
                                          verification: nil)
    }
}

extension ChangeMasterPasswordCoordinator: ChangeMasterPasswordWarningDelegate {
    func didCancel() {
        dismiss()
        logger.log(.warning(action: .cancel))
    }

    func didConfirm() {
        logger.log(.warning(action: .goToChangeMP))
        self.pushMasterPasswordInputViewController()
        logger.log(.enterNewMasterPasswordDisplayed)
    }
}

private extension PremiumService {
    func updatePremiumStatus(timeoutForRequest: TimeInterval, failure: @escaping () -> Void, success: @escaping (PremiumStatus) -> Void) {
        let failure = DispatchWorkItem {
            failure()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + timeoutForRequest, execute: failure)

        self.manager.updatePremiumStatus { (premiumStatus, _) in
            failure.cancel()
            success(premiumStatus)
        }
    }
}
