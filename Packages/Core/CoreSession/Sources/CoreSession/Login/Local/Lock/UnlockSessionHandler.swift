import CoreTypes
import Foundation
import SwiftTreats

public protocol UnlockSessionHandler: Sendable {
  func unlock(with masterKey: MasterKey) async throws -> Session
}

extension UnlockSessionHandler {
  public func validateMasterKey(_ masterKey: CoreSession.MasterKey) async throws -> Session {
    try await unlock(with: masterKey)
  }

  public func validateMasterKey(_ masterKey: CoreTypes.MasterKey) async throws -> Session {
    switch masterKey {
    case .masterPassword(let masterPassword):
      try await validateMasterKey(.masterPassword(masterPassword, serverKey: nil))
    case .key(let key):
      try await validateMasterKey(.ssoKey(key))
    }
  }
}

public struct UnlockSessionHandlerMock: UnlockSessionHandler {
  let validMasterKey: MasterKey
  let accountType: AccountType

  public init(validMasterKey: MasterKey, accountType: AccountType) {
    self.validMasterKey = validMasterKey
    self.accountType = accountType
  }

  public func unlock(with masterKey: MasterKey) async throws -> Session {
    guard isValidMasterKey(masterKey) else {
      throw MasterPasswordLocalLoginStateMachine.Error.wrongMasterKey
    }
    return .mock(accountType: accountType)
  }

  func isValidMasterKey(_ masterKey: MasterKey) -> Bool {
    switch (masterKey, validMasterKey) {
    case (
      let .masterPassword(lhsPassword, lhsServerKey), let .masterPassword(rhsPassword, rhsServerKey)
    ):
      return lhsPassword == rhsPassword && lhsServerKey == rhsServerKey
    case (let .ssoKey(lhsData), let .ssoKey(rhsData)):
      return lhsData == rhsData
    default:
      return false
    }
  }
}

extension UnlockSessionHandler where Self == UnlockSessionHandlerMock {
  public static func mock(
    masterKey: MasterKey = .masterPassword("_", serverKey: nil),
    accountType: AccountType = .masterPassword
  ) -> UnlockSessionHandler {
    UnlockSessionHandlerMock(validMasterKey: masterKey, accountType: accountType)
  }
}
