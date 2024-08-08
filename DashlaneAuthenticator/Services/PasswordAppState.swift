import CoreSession
import CoreSettings
import DashTypes
import Foundation

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
