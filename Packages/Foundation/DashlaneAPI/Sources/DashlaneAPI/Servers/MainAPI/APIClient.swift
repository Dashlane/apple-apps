import Foundation

protocol APIClient {
  var signer: RequestSigner? { get }
  var engine: APIClientEngine { get }
}

extension APIClient {
  func post<Response: Decodable, Body: Encodable>(
    _ endpoint: Endpoint,
    body: Body,
    timeout: TimeInterval? = nil
  ) async throws -> Response {
    return try await engine.post(endpoint, body: body, timeout: timeout, signer: signer)
  }

  func get<Response: Decodable>(_ endpoint: Endpoint, timeout: TimeInterval? = nil) async throws
    -> Response
  {
    return try await engine.get(endpoint, timeout: timeout, signer: signer)
  }
}

public typealias APIConfiguration = RequestConfiguration<AppAPIClient>

public struct UnsignedAPIClient: APIClient, Sendable {
  let engine: APIClientEngine
  let signer: RequestSigner?

  public init(configuration: APIConfiguration) {
    self.engine = APIClientEngineImpl(configuration: configuration)
    self.signer = nil
  }

  init(engine: APIClientEngine) {
    self.engine = engine
    self.signer = nil
  }
}

public struct AppAPIClient: APIClient, Sendable {
  let engine: APIClientEngine
  let timeshiftProvider: TimeshiftProvider
  let signer: RequestSigner?
  let configuration: APIConfiguration
  let appCredentials: AppCredentials

  public init(configuration: APIConfiguration, appCredentials: AppCredentials) {
    self.appCredentials = appCredentials
    self.configuration = configuration

    self.engine = APIClientEngineImpl(configuration: configuration)
    self.timeshiftProvider = TimeshiftProviderImpl(engine: engine)
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
