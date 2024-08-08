import CommonCrypto
import Foundation

struct CCStreamEncryptionEngine: StreamEncrypter {
  fileprivate let cryptor: CCCryptorRef

  func update(with data: Data) throws -> Data {
    return try data.withUnsafeBytes { bytes throws -> Data in
      let bufferSize = CCCryptorGetOutputLength(cryptor, data.count, false)
      var buffer = Data(count: bufferSize)
      var dataOutMovedLength = 0

      let status = buffer.withUnsafeMutableBytes {
        (output: UnsafeMutableRawBufferPointer) -> CCStatus in
        CCCryptorUpdate(
          cryptor,
          bytes.baseAddress,
          bytes.count,
          output.baseAddress,
          output.count,
          &dataOutMovedLength)
      }

      guard status == kCCSuccess else {
        throw EncryptionError(status: status)
      }

      return buffer[..<dataOutMovedLength]
    }
  }

  func finalize() throws -> Data {
    let bufferSize = CCCryptorGetOutputLength(cryptor, 0, true)
    var buffer = Data(count: bufferSize)
    var dataOutMovedLength = 0

    defer {
      CCCryptorRelease(cryptor)
    }

    guard bufferSize > 0 else {
      return Data()
    }

    let status = buffer.withUnsafeMutableBytes {
      (output: UnsafeMutableRawBufferPointer) -> CCStatus in
      CCCryptorFinal(
        cryptor,
        output.baseAddress,
        output.count,
        &dataOutMovedLength)
    }

    guard status == kCCSuccess else {
      throw EncryptionError(status: status)
    }

    return buffer[..<dataOutMovedLength]
  }
}

extension CCEncryptionEngine: StreamEncryptionEngine {
  private func makeStreamEngine(operation: CCOperation) throws -> CCStreamEncryptionEngine {
    try key.withUnsafeBytes { keyBytes throws -> CCStreamEncryptionEngine in
      return try initializationVector.withUnsafeBytes {
        initializationVector throws -> CCStreamEncryptionEngine in
        var cryptor: CCCryptorRef?
        let status = CCCryptorCreate(
          operation,
          CCAlgorithm(algorithm.rawValue),
          CCOptions(mode.CCValue | (padding?.CCValue ?? 0)),
          keyBytes.baseAddress,
          keyBytes.count,
          mode.hasInitialisationVector ? initializationVector.baseAddress : nil,
          &cryptor)

        guard status == kCCSuccess else {
          throw EncryptionError(status: status)
        }

        guard let cryptor else {
          throw EncryptionError.unspecifiedError
        }

        return CCStreamEncryptionEngine(cryptor: cryptor)
      }
    }
  }

  public func makeStreamEncrypter() throws -> StreamEncrypter {
    return try makeStreamEngine(operation: CCOperation(kCCEncrypt))
  }

  public func makeStreamDecrypter() throws -> StreamEncrypter {
    return try makeStreamEngine(operation: CCOperation(kCCDecrypt))
  }
}
