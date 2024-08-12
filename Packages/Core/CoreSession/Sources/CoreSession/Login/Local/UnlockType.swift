import DashlaneAPI
import Foundation

public enum UnlockType {
  case mpValidation
  case mpOtp2Validation(authTicket: AuthTicket?, serverKey: String)
  case ssoValidation(
    _ ssoAuthenticationInfo: SSOAuthenticationInfo, authTicket: AuthTicket? = nil,
    remoteKey: Data? = nil)

  public var isSso: Bool {
    switch self {
    case .ssoValidation: return true
    default: return false
    }
  }

  public var authTicket: AuthTicket? {
    switch self {
    case let .mpOtp2Validation(authTicket, _):
      return authTicket
    case let .ssoValidation(_, authTicket, _):
      return authTicket
    default:
      return nil
    }
  }
}

extension UnlockType {
  @MainActor func localLoginStep(
    with handler: LocalLoginHandler, session: Session, cryptoEngineProvider: CryptoEngineProvider,
    isRecoveryLogin: Bool
  ) -> LocalLoginHandler.Step {
    switch self {
    case let .ssoValidation(validator, authTicket, _):
      if let step = migrationstep(
        with: handler, session: session, authTicket: authTicket,
        cryptoEngineProvider: cryptoEngineProvider)
      {
        return step
      } else {
        if session.configuration.keys.remoteKey == nil {
          return .migrateSSOKeys(.unlock(session, validator))
        }
      }
    case let .mpOtp2Validation(authTicket, _):
      if let step = migrationstep(
        with: handler, session: session, authTicket: authTicket,
        cryptoEngineProvider: cryptoEngineProvider)
      {
        return step
      }
    case .mpValidation:
      if let step = migrationstep(
        with: handler, session: session, authTicket: nil, cryptoEngineProvider: cryptoEngineProvider
      ) {
        return step
      }
    }

    if session.configuration.keys.analyticsIds == nil {
      return .migrateAnalyticsId(session)
    } else {
      return .completed(session, isRecoveryLogin: isRecoveryLogin)
    }

  }

  @MainActor private func migrationstep(
    with handler: LocalLoginHandler, session: Session, authTicket: AuthTicket?,
    cryptoEngineProvider: CryptoEngineProvider
  ) -> LocalLoginHandler.Step? {
    if let ssoMigration = handler.ssoInfo,
      let type = ssoMigration.migration,
      let serviceProviderUrl = URL(
        string:
          "\(ssoMigration.serviceProviderUrl)?redirect=mobile&username=\(handler.login.email)&frag=true"
      )
    {
      return .migrateAccount(
        AccountMigrationInfos(
          session: session,
          type: type,
          ssoAuthenticationInfo: SSOAuthenticationInfo(
            login: handler.login, serviceProviderUrl: serviceProviderUrl,
            isNitroProvider: ssoMigration.isNitroProvider ?? false, migration: type),
          authTicket: authTicket))
    }
    return nil
  }

  func localLoginStep(with masterKey: MasterKey) -> LocalLoginHandler.Step? {
    if case let .ssoKey(ssoKey) = masterKey,
      case let UnlockType.ssoValidation(_, _, remoteKey) = self,
      let remoteKey = remoteKey
    {
      return .migrateSSOKeys(.localLogin(ssoKey: ssoKey, remoteKey: remoteKey))
    }
    return nil
  }
}
