import Foundation

public typealias APIConfiguration = ClientConfiguration<AppAPIClient>
typealias MainAPIClientEngineImpl = APIClientEngineImpl<AppAPIClient, APIError>

public struct AppAPIClient: APIClient, Sendable {
  let engine: APIClientEngine
  let timeshiftProvider: TimeshiftProvider
  let signer: RequestSigner?
  let configuration: APIConfiguration
  let appCredentials: AppCredentials

  public init(configuration: APIConfiguration, appCredentials: AppCredentials) {
    self.appCredentials = appCredentials
    self.configuration = configuration

    self.engine = MainAPIClientEngineImpl(configuration: configuration)
    let unsignedClient = UnsignedAPIClient(engine: engine)
    self.timeshiftProvider = TimeshiftProviderImpl(remoteTimeProvider: unsignedClient)
    self.signer = RequestSigner(
      appCredentials: appCredentials,
      userCredentials: nil,
      timeshiftProvider: timeshiftProvider)
  }

  init(
    engine: APIClientEngine,
    signer: RequestSigner,
    configuration: APIConfiguration,
    timeshiftProvider: TimeshiftProvider,
    appCredentials: AppCredentials
  ) {
    self.engine = engine
    self.signer = signer
    self.configuration = configuration
    self.timeshiftProvider = timeshiftProvider
    self.appCredentials = appCredentials
  }
}

extension AppAPIClient {
  public static var fake: AppAPIClient {
    return .mock(using: .init())
  }

  public static func mock(using mockEngine: APIMockerEngine) -> AppAPIClient {
    let appCredentials = AppCredentials(accessKey: "", secretKey: "")
    return AppAPIClient(
      engine: mockEngine,
      signer: RequestSigner(
        appCredentials: appCredentials,
        userCredentials: nil,
        timeshiftProvider: .mock()),
      configuration: try! APIConfiguration(info: .mock),
      timeshiftProvider: .mock(),
      appCredentials: appCredentials)
  }

  public static func mock(@APIMockBuilder _ requests: () -> [any MockedRequest]) -> AppAPIClient {
    return .mock(using: APIMockerEngine(requests: requests))
  }
}
