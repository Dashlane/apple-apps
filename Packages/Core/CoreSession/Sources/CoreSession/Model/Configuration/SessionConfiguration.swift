import CoreTypes
import Foundation

public struct SessionConfiguration: Equatable, Codable, Sendable {
  public let login: Login

  let masterKey: MasterKey
  public var keys: SessionSecureKeys
  public var info: SessionInfo

  public init(
    login: Login,
    masterKey: MasterKey,
    keys: SessionSecureKeys,
    info: SessionInfo
  ) {
    self.login = login
    self.masterKey = masterKey
    self.info = info
    self.keys = keys
  }
}

public struct SessionInfo: Codable, Equatable, Sendable {
  public let deviceAccessKey: String?
  public let loginOTPOption: ThirdPartyOTPOption?
  private let isPartOfSSOCompany: Bool
  public let accountType: AccountType

  public init(
    deviceAccessKey: String?,
    loginOTPOption: ThirdPartyOTPOption?,
    accountType: AccountType
  ) {
    self.deviceAccessKey = deviceAccessKey
    self.loginOTPOption = loginOTPOption
    self.accountType = accountType
    isPartOfSSOCompany = accountType == .sso
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.deviceAccessKey = try container.decodeIfPresent(String.self, forKey: .deviceAccessKey)
    do {
      self.loginOTPOption = try container.decodeIfPresent(
        ThirdPartyOTPOption.self, forKey: .loginOTPOption)
    } catch {
      self.loginOTPOption = .totp
    }
    self.isPartOfSSOCompany = try container.decode(Bool.self, forKey: .isPartOfSSOCompany)
    if let accountType = try container.decodeIfPresent(AccountType.self, forKey: .accountType) {
      self.accountType = accountType
    } else {
      self.accountType = isPartOfSSOCompany == true ? .sso : .masterPassword
    }
  }
}

public struct SessionSecureKeys: Codable, Equatable, Sendable {
  public let serverAuthentication: ServerAuthentication
  public let remoteKey: Data?
  public var analyticsIds: AnalyticsIdentifiers?

  public init(
    serverAuthentication: ServerAuthentication, remoteKey: Data?,
    analyticsIds: AnalyticsIdentifiers?
  ) {
    self.serverAuthentication = serverAuthentication
    self.remoteKey = remoteKey
    self.analyticsIds = analyticsIds
  }
}

extension SessionConfiguration {
  public static func mock(accountType: AccountType) -> SessionConfiguration {
    .init(
      login: .mock,
      masterKey: .masterPassword("_", serverKey: nil),
      keys: SessionSecureKeys.mock,
      info: SessionInfo.mock(accountType: accountType))
  }
}

extension SessionInfo {
  public static func mock(accountType: AccountType) -> SessionInfo {
    .init(
      deviceAccessKey: nil,
      loginOTPOption: nil,
      accountType: accountType)
  }
}

extension SessionSecureKeys {
  public static var mock: SessionSecureKeys {
    .init(
      serverAuthentication: .uki(.init(deviceId: "", secret: "")),
      remoteKey: nil,
      analyticsIds: nil)
  }
}

public enum AccountType: Codable, Equatable, Sendable {
  case masterPassword
  case invisibleMasterPassword
  case sso
}
