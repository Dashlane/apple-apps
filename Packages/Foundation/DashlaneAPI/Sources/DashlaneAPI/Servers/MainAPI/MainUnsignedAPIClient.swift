import Foundation

public struct UnsignedAPIClient: APIClient, Sendable {
  let engine: APIClientEngine
  let signer: RequestSigner?

  init(engine: APIClientEngine) {
    self.engine = engine
    self.signer = nil
  }
}

extension UnsignedAPIClient {
  public init(configuration: APIConfiguration) {
    self.engine = MainAPIClientEngineImpl(configuration: configuration)
    self.signer = nil
  }
}

extension UnsignedAPIClient: RemoteTimeProvider {
  func remoteTime() async throws -> Int {
    try await self.time.getRemoteTime().timestamp
  }
}
