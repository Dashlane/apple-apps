import Foundation

public typealias NitroSSOConfiguration = ClientConfiguration<NitroSSOAPIClient>
typealias NitroSSOAPIClientEngineImpl = APIClientEngineImpl<NitroSSOAPIClient, NitroSSOError>

public struct NitroSSOAPIClient: APIClient {
  let engine: APIClientEngine

  public init(configuration: NitroSSOConfiguration) throws {
    self.engine = NitroSSOAPIClientEngineImpl(configuration: configuration)
  }

  public init(engine: APIClientEngine) {
    self.engine = engine
  }
}

extension NitroSSOAPIClient {
  public func makeSecureNitroSSOAPIClient(secureTunnel: SecureTunnel) -> SecureNitroSSOAPIClient {
    return SecureNitroSSOAPIClient(engine: engine, secureTunnel: secureTunnel)
  }
}

extension NitroSSOAPIClient {
  public static var fake: NitroSSOAPIClient {
    return .mock(using: .init())
  }

  public static func mock(using mockEngine: APIMockerEngine) -> NitroSSOAPIClient {
    return NitroSSOAPIClient(engine: mockEngine)
  }

  public static func mock(@APIMockBuilder _ requests: () -> [any MockedRequest])
    -> NitroSSOAPIClient
  {
    return .mock(using: APIMockerEngine(requests: requests))
  }
}
