import Foundation
import Combine
import DashTypes

@MainActor
public protocol TOTPLoginViewModel: ObservableObject {
    
    var login: Login { get }
    var otp: String {get set}
    var errorMessage: String? { get set }
    var inProgress: Bool { get }
    var hasDuoPush: Bool {get}
    var hasAuthenticatorPush: Bool {get}
    var showDuoPush: Bool { get set }
    var showAuthenticatorPush: Bool { get set }
    var context: LocalLoginFlowContext { get }
    var loginInstallerLogger: LoginInstallerLogger { get }
    var lostOTPSheetViewModel: LostOTPSheetViewModel { get }
    func validate()
    func sendPush(_ type: PushType) async
    func useBackupCode(_ code: String)
    func logOnAppear()
    func makeAuthenticatorPushViewModel() -> AuthenticatorPushViewModel
}

extension TOTPLoginViewModel {
    public var canLogin: Bool {
        return !otp.isEmpty && !inProgress
    }
}

public enum PushType {
    case duo
    case authenticator
}
