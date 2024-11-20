import Foundation

public struct SecureNitroSSOAPIClient: APIClient {
  let engine: APIClientEngine

  public init(engine: APIClientEngine, secureTunnel: SecureTunnel) {
    self.engine = engine.secured(with: secureTunnel)
  }

  init(engine: APIClientEngine) {
    self.engine = engine
  }
}

extension SecureNitroSSOAPIClient {
  public static var fake: SecureNitroSSOAPIClient {
    return .mock(using: .init())
  }

  public static func mock(using mockEngine: APIMockerEngine) -> SecureNitroSSOAPIClient {
    return SecureNitroSSOAPIClient(engine: mockEngine)
  }

  public static func mock(@APIMockBuilder _ requests: () -> [any MockedRequest])
    -> SecureNitroSSOAPIClient
  {
    return .mock(using: APIMockerEngine(requests: requests))
  }
}
