import DashTypes
import Foundation
import SwiftTreats

public protocol UnlockSessionHandler {
  func unlock(with masterKey: MasterKey, isRecoveryLogin: Bool) async throws -> Session?
}

extension UnlockSessionHandler {
  public func validateMasterKey(_ masterKey: CoreSession.MasterKey) async throws -> Session? {
    try await unlock(with: masterKey, isRecoveryLogin: false)
  }

  public func validateMasterKey(_ masterKey: DashTypes.MasterKey) async throws -> Session? {
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

  public init(validMasterKey: MasterKey) {
    self.validMasterKey = validMasterKey
  }

  public func unlock(with masterKey: MasterKey, isRecoveryLogin: Bool) async throws -> Session? {
    guard masterKey == validMasterKey else {
      throw MasterPasswordLocalLoginStateMachine.Error.wrongMasterKey
    }
    return .mock
  }
}

extension UnlockSessionHandler where Self == UnlockSessionHandlerMock {
  public static func mock(masterKey: MasterKey = .masterPassword("_", serverKey: nil))
    -> UnlockSessionHandler
  {
    UnlockSessionHandlerMock(validMasterKey: masterKey)
  }
}
