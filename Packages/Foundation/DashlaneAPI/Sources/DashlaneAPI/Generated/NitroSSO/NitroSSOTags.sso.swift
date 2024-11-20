import Foundation

extension NitroSSOAPIClient {

  public struct Tunnel {
    let api: NitroSSOAPIClient
  }
  public var tunnel: Tunnel {
    Tunnel(api: self)
  }
}

extension SecureNitroSSOAPIClient {

  public struct Authentication {
    let api: SecureNitroSSOAPIClient
  }
  public var authentication: Authentication {
    Authentication(api: self)
  }
}
