import Foundation
import Combine
import CoreSession
import CoreUserTracking
import SwiftTreats
import DashTypes

@MainActor
public protocol MasterPasswordViewModel: ObservableObject {
    var login: Login { get }
    var attempts: Int { get }
    var password: String { get set }
    var errorMessage: String? { get set }
    var isExtension: Bool { get }
    func validate() async
    func logout()
    var inProgress: Bool { get }
    var sessionLifeCycleHandler: SessionLifeCycleHandler? { get }
    var shouldSuggestMPReset: Bool { get }
    var showWrongPasswordError: Bool { get }
    var installerLogService: InstallerLogServiceProtocol { get }
    func didTapResetMP()
    var biometry: Biometry? { get }
    var isSSOUser: Bool { get }
    func showBiometryView()
    func unlockWithSSO()
    func logLoginStatus(_ status: Definition.Status)
    func logForgotPassword()
    func logOnAppear()
}

public extension MasterPasswordViewModel {

    var sessionLifeCycleHandler: SessionLifeCycleHandler? {
        return nil
    }

    func showBiometryView() {}
    var biometry: Biometry? {
        return nil
    }
    func logout() {}
}
