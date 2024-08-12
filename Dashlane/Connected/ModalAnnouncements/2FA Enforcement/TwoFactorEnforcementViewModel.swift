import CoreSession
import DashlaneAPI
import Foundation

@MainActor
class TwoFactorEnforcementViewModel: ObservableObject, SessionServicesInjecting {

  @Published
  var isTwoFAEnabled: Bool = false

  let userDeviceAPIClient: UserDeviceAPIClient
  let lockService: LockServiceProtocol
  let logout: () -> Void

  init(
    userDeviceAPIClient: UserDeviceAPIClient,
    lockService: LockServiceProtocol,
    logout: @escaping () -> Void
  ) {
    self.userDeviceAPIClient = userDeviceAPIClient
    self.lockService = lockService
    self.logout = logout
  }

  func fetch() async {
    do {
      let response = try await userDeviceAPIClient.authentication.get2FAStatus()
      isTwoFAEnabled = response.type.twoFAType != nil
    } catch {}
  }
}

extension TwoFactorEnforcementViewModel {
  static var mock: TwoFactorEnforcementViewModel {
    .init(
      userDeviceAPIClient: UserDeviceAPIClient.fake,
      lockService: LockServiceMock(),
      logout: {})
  }
}
