import Foundation

public typealias NitroEncryptionAPIConfiguration = ClientConfiguration<AppNitroEncryptionAPIClient>
typealias NitroEncryptionAPIClientEngineImpl = APIClientEngineImpl<
  AppNitroEncryptionAPIClient, NitroEncryptionError
>

public struct AppNitroEncryptionAPIClient: APIClient {
  let engine: APIClientEngine
  let timeshiftProvider: TimeshiftProvider
  let signer: RequestSigner?
  let configuration: NitroEncryptionAPIConfiguration
  let appCredentials: AppCredentials

  public init(configuration: NitroEncryptionAPIConfiguration, appCredentials: AppCredentials) {
    self.appCredentials = appCredentials
    self.configuration = configuration

    self.engine = NitroEncryptionAPIClientEngineImpl(configuration: configuration)
    let unsignedClient = UnsignedNitroEncryptionAPIClient(engine: engine)
    self.timeshiftProvider = TimeshiftProviderImpl(remoteTimeProvider: unsignedClient)
    self.signer = RequestSigner(
      appCredentials: appCredentials,
      userCredentials: nil,
      timeshiftProvider: timeshiftProvider)
  }

  init(
    engine: APIClientEngine,
    signer: RequestSigner,
    configuration: NitroEncryptionAPIConfiguration,
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
  public func makeAppNitroEncryptionAPIClient() throws -> AppNitroEncryptionAPIClient {
    let configuration = try NitroEncryptionAPIConfiguration(
      info: configuration.info,
      environment: .init(environment: configuration.environment),
      defaultTimeout: configuration.defaultTimeout)
    return AppNitroEncryptionAPIClient(configuration: configuration, appCredentials: appCredentials)
  }
}

extension NitroEncryptionAPIConfiguration.Environment {
  init(environment: APIConfiguration.Environment) {
    switch environment {
    case .production:
      self = .production
    #if DEBUG || NIGHTLY
      case let .staging(info):
        let info = StagingInformation(
          apiURL: info.apiURL.deletingLastPathComponent()
            .appending(
              component: AppNitroEncryptionAPIClient.specDefinedServerURL.lastPathComponent),
          cloudflareIdentifier: info.cloudflareIdentifier,
          cloudflareSecret: info.cloudflareSecret)
        self = .staging(info)
    #endif
    }
  }
}

extension AppNitroEncryptionAPIClient {
  public static var fake: AppNitroEncryptionAPIClient {
    return .mock(using: .init())
  }

  public static func mock(using mockEngine: APIMockerEngine) -> AppNitroEncryptionAPIClient {
    let appCredentials = AppCredentials(accessKey: "", secretKey: "")
    let signer = RequestSigner(
      appCredentials: appCredentials,
      userCredentials: nil,
      timeshiftProvider: .mock())

    let configuration = try! NitroEncryptionAPIConfiguration(info: .mock)

    return AppNitroEncryptionAPIClient(
      engine: mockEngine,
      signer: signer,
      configuration: configuration,
      timeshiftProvider: .mock(),
      appCredentials: appCredentials)
  }

  public static func mock(@APIMockBuilder _ requests: () -> [any MockedRequest])
    -> AppNitroEncryptionAPIClient
  {
    return .mock(using: APIMockerEngine(requests: requests))
  }
}
