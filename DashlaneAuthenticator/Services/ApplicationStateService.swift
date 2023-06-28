import Foundation
import Combine
import DashTypes
import CoreSettings
import DashlaneAppKit
import DashlaneCrypto
import CoreSession
import CoreKeychain
import UIKit
import LoginKit

class ApplicationStateService: Mockable {

    enum State: Equatable {
        static func == (lhs: ApplicationStateService.State, rhs: ApplicationStateService.State) -> Bool {
            switch(lhs, rhs) {
            case (.paired, .paired):
                return true
            case (.standAlone, .standAlone):
                return true
            default:
                return false
            }
        }

        case loading
        case paired(PairedServicesContainer)
        case standAlone(StandAloneServicesContainer, PasswordAppState)
        case askForAuthentication(SessionLoadingInfo)
    }

    @Published
    var currentState: State = .loading
    let sessionsContainer: SessionsContainerProtocol
    let keychainService: AuthenticationKeychainServiceProtocol
    let settingsManager: SettingsManager
    let logger: Logger

    init(sessionsContainer: SessionsContainerProtocol,
         keychainService: AuthenticationKeychainServiceProtocol,
         logger: Logger,
         settingsManager: SettingsManager) {
        self.sessionsContainer = sessionsContainer
        self.keychainService = keychainService
        self.settingsManager = settingsManager
        self.logger = logger
    }

    func passwordAppState() -> PasswordAppState {

        guard let url = URL(string: "dashlane:///"), UIApplication.shared.canOpenURL(url) else {
            return .notInstalled
        }

        guard let contents = try? FileManager.default.contentsOfDirectory(at: ApplicationGroup.fiberSessionsURL, includingPropertiesForKeys: nil), !contents.isEmpty else {
            return .noAccount
        }
        
        guard let login = try? sessionsContainer.fetchCurrentLogin(),
              let settings = try? settingsManager.fetchOrCreateSettings(for: login) else {
            return .noLogin
        }

        guard ((try? sessionsContainer.sessionDirectory(for: login)) != nil),
              let info = try? sessionsContainer.info(for: login) else { 
                  return .noLogin
              }

        let secureLockProvider = SecureLockProvider(login: login,
                                                    settings: settings,
                                                    keychainService: keychainService)
        guard let authenticationMode = secureLockProvider.secureLockMode(checkIsBiometricSetIntact: false).authenticationMode else {
            return .noLock
        }
        return .locked(SessionLoadingInfo(login: login, settings: settings, authenticationMode: authenticationMode, loginOTPOption: info.loginOTPOption))
    }

    func move(to state: State) {
        DispatchQueue.main.async {
            self.currentState = state
        }
    }

    func handle(_ message: PasswordAppMessage) {
        switch message {
                    case .sync: break
        case .login, .logout, .lockSettingsChanged:
            move(to: .loading)
        case .refresh:
            switch currentState {
            case .paired(let services):
                services.databaseService.load()
            case .standAlone(let services, _):
                services.databaseService.load()
            case .askForAuthentication: break
            case .loading: break
            }
        }
    }
}
