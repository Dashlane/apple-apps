import Foundation

extension AppNitroEncryptionAPIClient {

  public struct Tunnel {
    let api: AppNitroEncryptionAPIClient
  }
  public var tunnel: Tunnel {
    Tunnel(api: self)
  }
}

extension UnsignedNitroEncryptionAPIClient {

  public struct Time {
    let api: UnsignedNitroEncryptionAPIClient
  }
  public var time: Time {
    Time(api: self)
  }
}

extension UserSecureNitroEncryptionAPIClient {

  public struct Logs {
    let api: UserSecureNitroEncryptionAPIClient
  }
  public var logs: Logs {
    Logs(api: self)
  }
}
