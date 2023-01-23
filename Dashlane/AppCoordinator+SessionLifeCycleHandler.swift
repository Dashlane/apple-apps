import Foundation
import CoreSession
import Combine
import DashlaneReportKit
import CoreUserTracking
import DashlaneAppKit
import SwiftUI
import LoginKit
import DashTypes

extension AppCoordinator: SessionLifeCycleHandler {
    var sessionState: SessionState {
        if let connectedCoordinator = self.connectedCoordinator {
            switch connectedCoordinator.sessionServices.lockService.locker {
            case let .screenLock(screenLocker):
                return .connected(isLocked: screenLocker.lock != nil)
            case .automaticLogout:
                return .connected(isLocked: false)
            }
        } else {
            return .disconnected
        }
    }

    func automaticLogout() {
        guard let login = connectedCoordinator?.sessionServices.session.login else {
            return
        }
        if let settings = try? appServices.spiegelSettingsManager.fetchOrCreateUserSettings(for: login) {
            settings[.automaticallyLoggedOut] = true
        }
        logout(clearAutoLoginData: false)
    }

    func logout(clearAutoLoginData: Bool = true) {
        guard let session = connectedCoordinator?.sessionServices.session else {
            return
        }
        logout(for: session, clearAutoLoginData: clearAutoLoginData)
    }

    private func logout(for session: Session, clearAutoLoginData: Bool = true) {
        connectedCoordinator?.sessionServices.unload(reason: .userLogsOut)
        sessionServicesSubscription?.cancel()
        GlobalEnvironmentValues.popActiveEnvironment()

        if clearAutoLoginData {
            self.appServices.sessionCleaner.cleanAutoLoginData(for: session.login)
        }
        connectedCoordinator?.dismiss {
            self.currentSubCoordinator = nil
            self.navigator.dismiss(animated: false)
            self.createSessionFromSavedLogin()
        }
    }

    func logoutAndPerform(action: PostLogoutAction) {
        switch action {
        case let .startNewSession(newSession, reason):
            logoutAndStartNewSession(newSession, reason: reason)
        case .deleteCurrentSessionLocalData:
            logoutAndDeleteLocalData()
        case let .deleteLocalData(session):
            logoutAndDeleteLocalData(for: session)
        }
    }

    private func logoutAndDeleteLocalData() {
        guard let session = connectedCoordinator?.sessionServices.session else {
            return
        }
        logoutAndDeleteLocalData(for: session)
    }

    private func logoutAndDeleteLocalData(for session: Session) {
        connectedCoordinator?.sessionServices.unload(reason: .userLogsOut)
        sessionServicesSubscription?.cancel()
        GlobalEnvironmentValues.popActiveEnvironment()

        connectedCoordinator?.dismiss {
            self.currentSubCoordinator = nil
            self.appServices.sessionCleaner.removeLocalData(for: session.login)
            self.showOnboarding()
        }
    }

        private func logoutAndStartNewSession(_ newSession: Session, reason: SessionServicesUnloadReason) {
        connectedCoordinator?.sessionServices.unload(reason: reason)
        sessionServicesSubscription?.cancel()
        GlobalEnvironmentValues.popActiveEnvironment()

        connectedCoordinator?.dismiss { [weak self] in
            guard let self = self else { return }
            self.currentSubCoordinator = nil
            self.navigator.dismiss(animated: false)
            self.sessionServicesSubscription = SessionServicesContainer
                .buildSessionServices(from: newSession,
                                      appServices: self.appServices,
                                      logger: self.sessionLogger,
                                      loadingContext: .localLogin) { [weak self] result in
                                        DispatchQueue.main.async {
                                            guard let self = self else { return }

                                            switch result {
                                            case let .success(sessionServices):
                                                self.startConnectedCoordinator(using: sessionServices)
                                            case .failure:
                                                                                                self.showOnboarding()
                                            }
                                        }
            }
        }
    }
}
