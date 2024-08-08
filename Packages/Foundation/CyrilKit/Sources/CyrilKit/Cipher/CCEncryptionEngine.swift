import CommonCrypto
import CryptoKit
import Foundation

struct CCEncryptionEngine: EncryptionEngine {
  enum Algorithm: Int {
    case aes
    case blowFish

    var rawValue: Int {
      switch self {
      case .aes:
        return kCCAlgorithmAES
      case .blowFish:
        return kCCAlgorithmBlowfish
      }
    }
  }

  enum Mode {
    case cbc
    case ecb

    var hasInitialisationVector: Bool {
      switch self {
      case .cbc:
        return true
      case .ecb:
        return false
      }
    }

    var CCValue: Int {
      switch self {
      case .cbc:
        return 0
      case .ecb:
        return kCCOptionECBMode
      }
    }
  }

  let algorithm: Algorithm
  let mode: Mode
  let padding: Padding?
  let bufferSize: Int?
  let key: SymmetricKey
  let initializationVector: Data

  init(
    algorithm: Algorithm,
    mode: Mode,
    padding: Padding?,
    key: SymmetricKey,
    initializationVector: Data,
    bufferSize: Int? = nil
  ) throws {
    self.algorithm = algorithm
    self.mode = mode
    self.padding = padding
    self.key = key
    self.initializationVector = initializationVector
    self.bufferSize = bufferSize

    if !algorithm.validateKeySize(key.count) {
      throw EncryptionError.wrongKeySize
    }

    if mode.hasInitialisationVector && initializationVector.count < algorithm.blockSize {
      throw EncryptionError.wrongInitialisationVectorSize
    }
  }

  @inline(__always)
  private func perform(_ operation: CCOperation, on data: Data) throws -> Data {
    return try key.withUnsafeBytes { keyBytes throws -> Data in
      return try initializationVector.withUnsafeBytes { initializationVector throws -> Data in
        return try data.withUnsafeBytes { bytes throws -> Data in
          let bufferSize = bufferSize ?? bytes.count + algorithm.blockSize

          var buffer = Data(count: bufferSize)
          var dataOutMovedLength = 0

          let status = buffer.withUnsafeMutableBytes {
            (output: UnsafeMutableRawBufferPointer) -> CCStatus in
            return CCCrypt(
              operation,
              CCAlgorithm(algorithm.rawValue),
              CCOptions(mode.CCValue | (padding?.CCValue ?? 0)),
              keyBytes.baseAddress,
              keyBytes.count,
              mode.hasInitialisationVector ? initializationVector.baseAddress : nil,
              bytes.baseAddress,
              bytes.count,
              output.baseAddress,
              output.count,
              &dataOutMovedLength)
          }

          guard status == kCCSuccess else {
            let error = EncryptionError(status: status)
            if error == .bufferTooSmall {
              return try CCEncryptionEngine(
                algorithm: algorithm,
                mode: mode,
                padding: padding,
                key: key,
                initializationVector: self.initializationVector,
                bufferSize: dataOutMovedLength
              ).perform(operation, on: data)
            } else {
              throw error
            }
          }

          return buffer[..<dataOutMovedLength]
        }
      }
    }
  }

  func encrypt(_ data: Data) throws -> Data {
    return try perform(CCOperation(kCCEncrypt), on: data)
  }

  func decrypt(_ data: Data) throws -> Data {
    return try perform(CCOperation(kCCDecrypt), on: data)
  }
}

extension CCEncryptionEngine.Algorithm {
  func validateKeySize(_ keySize: Int) -> Bool {
    switch self {
    case .aes:
      return keySize == kCCKeySizeAES256 || keySize == kCCKeySizeAES192
        || keySize == kCCKeySizeAES128
    case .blowFish:
      return (kCCKeySizeMinBlowfish...kCCKeySizeMaxBlowfish).contains(keySize)
    }
  }

  var blockSize: Int {
    switch self {
    case .aes:
      return kCCBlockSizeAES128
    case .blowFish:
      return kCCBlockSizeBlowfish
    }
  }
}

extension Padding {
  var CCValue: Int {
    switch self {
    case .pkcs7:
      return kCCOptionPKCS7Padding
    }
  }
}

public enum EncryptionError: Error, Equatable {
  case wrongKeySize
  case wrongInitialisationVectorSize
  case bufferTooSmall
  case paramError
  case memoryFailure
  case alignmentError
  case decodeError
  case unimplemented
  case overflow
  case rngFailure
  case unspecifiedError
  case callSequenceError
  case keySizeError
  case invalidKey
  case unknown(status: CCStatus)
}

extension EncryptionError {
  init(status: CCStatus) {
    switch Int(status) {
    case kCCParamError:
      self = .paramError

    case kCCBufferTooSmall:
      self = .bufferTooSmall

    case kCCMemoryFailure:
      self = .memoryFailure

    case kCCAlignmentError:
      self = .alignmentError

    case kCCDecodeError:
      self = .decodeError

    case kCCUnimplemented:
      self = .unimplemented

    case kCCOverflow:
      self = .overflow

    case kCCRNGFailure:
      self = .rngFailure

    case kCCUnspecifiedError:
      self = .unspecifiedError

    case kCCCallSequenceError:
      self = .callSequenceError

    case kCCKeySizeError:
      self = .keySizeError

    case kCCInvalidKey:
      self = .invalidKey

    default:
      self = .unknown(status: status)
    }

  }
}
