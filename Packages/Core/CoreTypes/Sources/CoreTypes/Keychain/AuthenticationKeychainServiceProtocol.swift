import Combine
import Foundation
import LocalAuthentication

public typealias UserLogin = String

public protocol AuthenticationKeychainServiceProtocol: Sendable {
  var defaultPasswordValidityPeriod: TimeInterval { get }
  var defaultRemoteKeyValidityPeriod: TimeInterval { get }

  nonisolated var masterKeyStatusChanged: PassthroughSubject<MasterKeyStatusChange, Never> { get }

  func masterKeyStatus(for login: Login) -> MasterKeyStoredStatus
  func masterKey(for login: Login, using context: LAContext?) throws -> MasterKey
  func save(
    _ masterKey: MasterKey, for login: Login, expiresAfter timeInterval: TimeInterval,
    accessMode: KeychainAccessMode) throws
  func removeMasterKey(for login: Login) throws

  func pincode(for login: Login) throws -> String
  func setPincode(_ pincode: String?, for login: Login) throws

  func serverKey(for login: Login) -> String?
  func saveServerKey(_ serverKey: String, for login: Login) throws
  func removeServerKey(for login: Login) throws

  func removeAllLocalData() throws
  func masterPasswordEquals(_ masterPassword: String, for login: Login) throws -> Bool
  func makeResetContainerKeychainManager(userLogin: UserLogin) -> ResetContainerKeychainManager
}

public enum MasterKeyStatusChange {
  case update(MasterKey)
  case removal
}

extension AuthenticationKeychainServiceProtocol {
  public var defaultPasswordValidityPeriod: TimeInterval {
    60 * 60 * 24 * 14
  }

  public var defaultRemoteKeyValidityPeriod: TimeInterval {
    TimeInterval.infinity
  }
}
