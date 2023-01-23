import Foundation
import DashTypes
import DashlaneAppKit
import CoreSession
import CoreSettings

enum PasswordAppState {
    case notInstalled
    case noAccount
    case noLogin
    case noLock
    case locked(SessionLoadingInfo)
}

struct SessionLoadingInfo {
    let login: Login
    let settings: LocalSettingsStore
    let authenticationMode: AuthenticationMode
    let loginOTPOption: ThirdPartyOTPOption?
}
