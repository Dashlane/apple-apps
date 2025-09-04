import AuthenticationServices
import Combine
import CoreTypes
import Foundation

public protocol IdentityStore {
  func getState(_ completion: @escaping (ASCredentialIdentityStoreState) -> Void)

  func saveCredentialIdentities(
    _ credentialIdentities: [ASCredentialIdentity], completion: ((Bool, Error?) -> Void)?)

  func removeCredentialIdentities(
    _ credentialIdentities: [ASCredentialIdentity], completion: ((Bool, Error?) -> Void)?)

  func replaceCredentialIdentities(
    _ newCredentialIdentities: [ASCredentialIdentity], completion: ((Bool, Error?) -> Void)?)

  func removeAllCredentialIdentities(_ completion: ((Bool, Error?) -> Void)?)
}

extension IdentityStore {
  func state() async -> ASCredentialIdentityStoreState {
    await withCheckedContinuation { continuation in
      getState { state in
        continuation.resume(returning: state)
      }
    }
  }

  func saveCredentialIdentities(_ credentialIdentities: [ASCredentialIdentity]) async throws {
    try await withCheckedThrowingContinuation { continuation in
      saveCredentialIdentities(credentialIdentities) { success, error in
        continuation.resume(withSuccess: success, error: error)
      }
    }
  }

  func removeCredentialIdentities(_ credentialIdentities: [ASCredentialIdentity]) async throws {
    try await withCheckedThrowingContinuation { continuation in
      removeCredentialIdentities(credentialIdentities) { success, error in
        continuation.resume(withSuccess: success, error: error)
      }
    }
  }

  func replaceCredentialIdentities(_ newCredentialIdentities: [ASCredentialIdentity]) async throws {
    try await withCheckedThrowingContinuation { continuation in
      replaceCredentialIdentities(newCredentialIdentities) { success, error in
        continuation.resume(withSuccess: success, error: error)
      }
    }
  }

  func removeAllCredentialIdentities() async throws {
    try await withCheckedThrowingContinuation { continuation in
      removeAllCredentialIdentities { success, error in
        continuation.resume(withSuccess: success, error: error)
      }
    }
  }
}

extension CheckedContinuation<(), Error> {
  func resume(withSuccess success: Bool, error: Error?) {
    if success {
      resume()
    } else if let error {
      resume(throwing: error)
    } else {
      resume(throwing: UnknownIdentityStoreError())
    }
  }
}

public struct UnknownIdentityStoreError: Error {}

extension IdentityStore {
  func status() async -> AutofillActivationStatus {
    await state().isEnabled ? .enabled : .disabled
  }
}

extension ASCredentialIdentityStore: IdentityStore {
  public func statePublisher() -> AnyPublisher<AutofillActivationStatus, Never> {
    return Future.init { completion in
      self.getState { storeState in
        completion(.success(storeState.isEnabled ? .enabled : .disabled))
      }
    }.eraseToAnyPublisher()
  }
}

extension ASCredentialIdentityStoreState {
  class ASCredentialIdentityStoreStateMock: ASCredentialIdentityStoreState {
    let overrideIsEnabled: Bool
    let overrideSupportsIncrementalUpdates: Bool

    override var isEnabled: Bool {
      overrideIsEnabled
    }

    override var supportsIncrementalUpdates: Bool {
      overrideSupportsIncrementalUpdates
    }

    init(isEnabled: Bool, supportsIncrementalUpdates: Bool) {
      overrideIsEnabled = isEnabled
      overrideSupportsIncrementalUpdates = supportsIncrementalUpdates
    }
  }

  public static func mock(isEnabled: Bool, supportsIncrementalUpdates: Bool)
    -> ASCredentialIdentityStoreState
  {
    ASCredentialIdentityStoreStateMock(
      isEnabled: isEnabled, supportsIncrementalUpdates: supportsIncrementalUpdates)
  }
}
