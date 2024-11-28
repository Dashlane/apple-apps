import Foundation

public struct UserDeviceAPIClient: APIClient, Sendable {
  let configuration: APIConfiguration
  let appCredentials: AppCredentials
  let userCredentials: UserCredentials
  let signer: RequestSigner?
  let engine: APIClientEngine

  init(
    configuration: APIConfiguration,
    appCredentials: AppCredentials,
    userCredentials: UserCredentials,
    timeshiftProvider: TimeshiftProvider,
    engine: APIClientEngine
  ) {
    self.configuration = configuration
    self.appCredentials = appCredentials
    self.userCredentials = userCredentials
    self.engine = engine
    self.signer = RequestSigner(
      appCredentials: appCredentials,
      userCredentials: userCredentials,
      timeshiftProvider: timeshiftProvider)
  }
}

extension AppAPIClient {
  public func makeUserClient(credentials: UserCredentials) -> UserDeviceAPIClient {
    return UserDeviceAPIClient(
      configuration: configuration,
      appCredentials: appCredentials,
      userCredentials: credentials,
      timeshiftProvider: timeshiftProvider,
      engine: engine)
  }
}

extension UserDeviceAPIClient {
  public static var fake: UserDeviceAPIClient {
    return .mock(using: .init())
  }

  public static func mock(using mockEngine: APIMockerEngine) -> UserDeviceAPIClient {
    let credentials = UserCredentials(login: "", deviceAccessKey: "", deviceSecretKey: "")
    return AppAPIClient.mock(using: mockEngine).makeUserClient(credentials: credentials)
  }

  public static func mock(@APIMockBuilder _ requests: () -> [any MockedRequest])
    -> UserDeviceAPIClient
  {
    return .mock(using: APIMockerEngine(requests: requests))
  }
}
