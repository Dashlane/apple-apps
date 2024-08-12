import DashTypes
import DashlaneAPI
import Foundation

extension AppAPIClient {
  func accountRecoveryInfo(for login: Login) async throws -> AccountRecoveryInfo {
    let isEnabled = try await accountrecovery.getStatus(login: login.email).enabled
    let accountType = try await authentication.getAuthenticationMethodsForDevice(
      login: login.email, methods: [.emailToken, .duoPush, .totp]
    ).accountType
    return AccountRecoveryInfo(
      login: login, isEnabled: isEnabled, accountType: try accountType.userAccountType)
  }
}
