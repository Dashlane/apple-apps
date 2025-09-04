import BrazeKit
import CoreFeature
import CoreSettings
import CoreTypes
import DashlaneAPI
import Foundation

extension BrazeService {

  public func registerLogin(
    _ login: Login,
    using userSettings: UserSettings,
    userDeviceAPIClient: UserDeviceAPIClient,
    featureService: FeatureServiceProtocol
  ) async {
    guard shouldLinkBrazeToUser(featureService: featureService) else {
      return
    }

    guard let publicUserId: String = userSettings[.publicUserId] else {
      do {
        let publicUserId = try await userDeviceAPIClient.account.accountInfo().publicUserId
        userSettings[.publicUserId] = publicUserId
        updateUser(login: login, publicUserId: publicUserId)
      } catch {
      }
      return
    }
    updateUser(login: login, publicUserId: publicUserId)

  }

  private func updateUser(login: Login, publicUserId: String) {
    #if DEBUG
      if login.isTest {
        braze?.changeUser(userId: login.email)
      } else {
        braze?.changeUser(userId: publicUserId)
      }
    #else
      braze?.changeUser(userId: publicUserId)
    #endif
  }
}
