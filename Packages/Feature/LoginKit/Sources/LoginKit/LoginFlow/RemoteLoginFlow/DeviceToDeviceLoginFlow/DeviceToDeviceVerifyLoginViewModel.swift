import Foundation
import CoreSession
import DashTypes

@MainActor
class DeviceToDeviceVerifyLoginViewModel: ObservableObject {

    enum Completion {
       case confirm
        case cancel
    }

    let loginData: DevciceToDeviceTransferData
    let completion: (Completion) -> Void
    let loginHandler: DeviceToDeviceLoginHandler
    let sessionCleaner: SessionCleaner

    @Published
    var isLoading = false

    @Published
    var showError = false

    init(loginData: DevciceToDeviceTransferData, sessionCleaner: SessionCleaner, loginHandler: DeviceToDeviceLoginHandler, completion: @escaping (Completion) -> Void) {
        self.loginData = loginData
        self.completion = completion
        self.loginHandler = loginHandler
        self.sessionCleaner = sessionCleaner
    }

    func confirm() {
        isLoading = true
        Task {
            do {
                sessionCleaner.removeLocalData(for: Login(loginData.login))
                try await loginHandler.verifiedLogin(for: loginData)
                completion(.confirm)
            } catch {
                showError = true
            }
        }
    }

    func cancel() {
        completion(.cancel)
    }
}
