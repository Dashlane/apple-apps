import Foundation

public struct UnsignedNitroEncryptionAPIClient: APIClient, Sendable {
  let engine: APIClientEngine
  let signer: RequestSigner?

  init(engine: APIClientEngine) {
    self.engine = engine
    self.signer = nil
  }
}

extension UnsignedNitroEncryptionAPIClient: RemoteTimeProvider {
  func remoteTime() async throws -> Int {
    try await self.time.getRemoteTime().timestamp
  }
}
