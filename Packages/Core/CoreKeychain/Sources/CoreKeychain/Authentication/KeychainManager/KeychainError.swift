import Foundation

public enum KeychainError: Error, Equatable {
  case userCanceledRequest

  case userFailedAuthCheck

  case itemNotFound

  case emptyItemData(status: OSStatus)

  case accessFailure(status: OSStatus)

  case decryptionFailure

  case encryptionFailure

  case removalFailure(status: OSStatus)

  case storingFailure(status: OSStatus)

  case settingsFailure

  case statusCheckFailure(status: OSStatus)

  case unhandledError(status: OSStatus)

  case unknown
}
