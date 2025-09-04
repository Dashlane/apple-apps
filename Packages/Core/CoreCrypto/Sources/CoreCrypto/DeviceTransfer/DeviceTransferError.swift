import Foundation
import LogFoundation

@Loggable
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
