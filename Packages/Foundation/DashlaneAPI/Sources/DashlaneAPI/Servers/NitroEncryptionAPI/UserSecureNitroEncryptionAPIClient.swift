import Foundation

public struct UserSecureNitroEncryptionAPIClient: APIClient {
  let engine: APIClientEngine
  let signer: RequestSigner?

  public init(
    engine: APIClientEngine,
    signer: RequestSigner,
    secureTunnel: SecureTunnel
  ) {
    self.engine = engine.secured(with: secureTunnel)
    self.signer = signer
  }

  init(engine: APIClientEngine) {
    self.engine = engine
    self.signer = nil
  }
}

extension AppNitroEncryptionAPIClient {
  func makeSecureNitroEncryptionAPIClient(
    secureTunnel: SecureTunnel,
    userCredentials: UserCredentials
  ) throws -> UserSecureNitroEncryptionAPIClient {
    let signer = RequestSigner(
      appCredentials: appCredentials,
      userCredentials: userCredentials,
      timeshiftProvider: timeshiftProvider)
    return UserSecureNitroEncryptionAPIClient(
      engine: engine, signer: signer, secureTunnel: secureTunnel)
  }
}
