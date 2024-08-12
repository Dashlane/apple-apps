import Foundation

extension NitroAPIClient {

  public struct Tunnel {
    let api: NitroAPIClient
  }
  public var tunnel: Tunnel {
    Tunnel(api: self)
  }
}

extension NitroSecureAPIClient {

  public struct Authentication {
    let api: NitroSecureAPIClient
  }
  public var authentication: Authentication {
    Authentication(api: self)
  }
}
