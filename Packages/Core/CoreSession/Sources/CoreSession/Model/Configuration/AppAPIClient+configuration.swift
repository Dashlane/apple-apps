import CoreTypes
import DashlaneAPI
import Foundation

extension AppAPIClient {
  public func makeUserClient(sessionConfiguration: SessionConfiguration) -> UserDeviceAPIClient {
    let signedAuthentication = sessionConfiguration.keys.serverAuthentication.signedAuthentication

    return self.makeUserClient(
      login: sessionConfiguration.login, signedAuthentication: signedAuthentication)
  }

  public func makeUserClient(login: Login, signedAuthentication: SignedAuthentication)
    -> UserDeviceAPIClient
  {
    return self.makeUserClient(
      credentials: UserCredentials(
        login: login.email,
        deviceAccessKey: signedAuthentication.deviceAccessKey,
        deviceSecretKey: signedAuthentication.deviceSecretKey))
  }
}

extension UserCredentials {
  public init(configuration: SessionConfiguration) {
    let signedAuthentication = configuration.keys.serverAuthentication.signedAuthentication
    self.init(
      login: configuration.login.email,
      deviceAccessKey: signedAuthentication.deviceAccessKey,
      deviceSecretKey: signedAuthentication.deviceSecretKey)
  }
}
