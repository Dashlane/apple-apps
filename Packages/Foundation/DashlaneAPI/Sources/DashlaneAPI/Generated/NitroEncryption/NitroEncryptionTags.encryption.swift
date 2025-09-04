import Foundation

extension AppNitroEncryptionAPIClient {

  public struct Tunnel: Sendable {
    let api: AppNitroEncryptionAPIClient
  }
  public var tunnel: Tunnel {
    Tunnel(api: self)
  }
}

extension UnsignedNitroEncryptionAPIClient {

  public struct Time: Sendable {
    let api: UnsignedNitroEncryptionAPIClient
  }
  public var time: Time {
    Time(api: self)
  }
}

extension UserSecureNitroEncryptionAPIClient {

  public struct Logs: Sendable {
    let api: UserSecureNitroEncryptionAPIClient
  }
  public var logs: Logs {
    Logs(api: self)
  }

  public struct Passkeys: Sendable {
    let api: UserSecureNitroEncryptionAPIClient
  }
  public var passkeys: Passkeys {
    Passkeys(api: self)
  }

  public struct Uvvs: Sendable {
    let api: UserSecureNitroEncryptionAPIClient
  }
  public var uvvs: Uvvs {
    Uvvs(api: self)
  }
}
