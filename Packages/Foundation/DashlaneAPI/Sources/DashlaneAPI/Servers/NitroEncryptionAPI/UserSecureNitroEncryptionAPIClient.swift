import Foundation

public struct UserSecureNitroEncryptionAPIClient: APIClient {
  let engine: APIClientEngine
  let signer: RequestSigner?

  public init(
    appClient: AppNitroEncryptionAPIClient,
    signer: RequestSigner,
    secureTunnelCreatorType: any NitroSecureTunnelCreator.Type
  ) {
    self.engine = NitroEncryptionSecuredAPIClientEngine(
      secureTunnelCreatorType: secureTunnelCreatorType,
      appClient: appClient)
    self.signer = signer
  }

  init(engine: APIClientEngine) {
    self.engine = engine
    self.signer = nil
  }
}

extension AppNitroEncryptionAPIClient {
  public func makeSecureNitroEncryptionAPIClient(
    secureTunnelCreatorType: any NitroSecureTunnelCreator.Type,
    userCredentials: UserCredentials
  ) -> UserSecureNitroEncryptionAPIClient {
    let signer = RequestSigner(
      appCredentials: appCredentials,
      userCredentials: userCredentials,
      timeshiftProvider: timeshiftProvider)
    return UserSecureNitroEncryptionAPIClient(
      appClient: self,
      signer: signer,
      secureTunnelCreatorType: secureTunnelCreatorType)
  }
}

extension UserSecureNitroEncryptionAPIClient {
  public static var fake: UserSecureNitroEncryptionAPIClient {
    return .mock(using: .init())
  }

  public static func mock(using mockEngine: APIMockerEngine) -> UserSecureNitroEncryptionAPIClient {
    return UserSecureNitroEncryptionAPIClient(engine: mockEngine)
  }

  public static func mock(@APIMockBuilder _ requests: () -> [any MockedRequest])
    -> UserSecureNitroEncryptionAPIClient
  {
    return .mock(using: APIMockerEngine(requests: requests))
  }
}
