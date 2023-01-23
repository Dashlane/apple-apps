import Foundation
import Combine
import DashlaneAppKit
import DashTypes

class LoginViewModel: ObservableObject {
    
    let sessionSharing: MainApplicationSessionSharingProtocol
    let appSettings: AppSettings
    let loginError: String?
    
    @Published
    var shouldShowReactivationWebcardEnabler: Bool = false
    
    init(sessionSharing: MainApplicationSessionSharingProtocol, appSettings: AppSettings, loginError: String?) {
        self.sessionSharing = sessionSharing
        self.appSettings = appSettings
        self.loginError = loginError
    }
    
    func openMainApplication() {
        sessionSharing.askForSession(silently: false)
    }
    
    func appeared() {
        refreshRectivationEnabled()
    }
    
    func enableReactivationWebcard() {
        shouldShowReactivationWebcardEnabler = false
        appSettings.safariWebCardActivated = nil
    }
    
    private func refreshRectivationEnabled() {
        guard BuildEnvironment.current != .appstore else {
            shouldShowReactivationWebcardEnabler = false
            return
        }
        shouldShowReactivationWebcardEnabler = appSettings.safariWebCardActivated == false
    }
}


extension LoginViewModel {
    static var mock: LoginViewModel {
        LoginViewModel(sessionSharing: MainApplicationSessionSharingMock(),
                       appSettings: AppSettings(),
                       loginError: nil)
    }
}
