import Foundation

public protocol NitroSecureTunnelCreator {
  var publicKey: String { get }

  init() throws

  func create(withRawAttestation attestation: String) throws -> any SecureTunnel
}

public struct NitroSecureTunnelCreatorMock: NitroSecureTunnelCreator {
  nonisolated(unsafe) public static var tunnelCount: Int = 0
  public let publicKey: String

  public init() throws {
    publicKey = "mockPublicKey" + UUID().uuidString
    Self.tunnelCount += 1
  }

  public func create(withRawAttestation attestation: String) throws -> any SecureTunnel {
    return SecureTunnelMock()
  }

}
