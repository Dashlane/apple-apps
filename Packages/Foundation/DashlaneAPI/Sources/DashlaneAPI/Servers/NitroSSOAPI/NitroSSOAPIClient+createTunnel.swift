import Foundation

extension NitroSSOAPIClient {
  public func makeSecureNitroSSOAPIClient(secureTunnel: SecureTunnel) -> SecureNitroSSOAPIClient {
    return SecureNitroSSOAPIClient(engine: engine, secureTunnel: secureTunnel)
  }

  public func createSecureNitroSSOAPIClient(
    using secureTunnelCreatorType: NitroSecureTunnelCreator.Type
  ) async throws -> SecureNitroSSOAPIClient {
    let secureTunnelCreator = try secureTunnelCreatorType.init()
    let response = try await tunnel.clientHello(clientPublicKey: secureTunnelCreator.publicKey)
    let secureTunnel = try secureTunnelCreator.create(withRawAttestation: response.attestation)
    try await tunnel.terminateHello(clientHeader: secureTunnel.header)

    return makeSecureNitroSSOAPIClient(secureTunnel: secureTunnel)
  }
}
