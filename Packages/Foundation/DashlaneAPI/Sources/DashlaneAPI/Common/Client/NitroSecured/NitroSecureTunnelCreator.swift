import Foundation

public protocol NitroSecureTunnelCreator {
  func createTunnel() async throws -> SecureTunnel
}

public struct NitroSecureTunnelCreatorMock: NitroSecureTunnelCreator {

  let response: Any

  public init(response: Any) {
    self.response = response
  }

  public func createTunnel() async throws -> any SecureTunnel {
    .mock(response: response)
  }
}
