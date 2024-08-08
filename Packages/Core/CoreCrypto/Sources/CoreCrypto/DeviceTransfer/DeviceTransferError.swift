import Foundation

public enum DeviceTransferError: Error {
  case couldNotGenerateKeyPair

  case hashGenerationFailed

  case couldNotGenerateServerSharedSecret

  case couldNotGenerateClientSharedSecret

  case couldNotGenerateSeed

  case couldNotGenerateSymmetricKey

  case publicKeyHashNotMatching

  case invalidFormat
}
