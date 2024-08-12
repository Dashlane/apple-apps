import CyrilKit
import Foundation

import struct CryptoKit.HMAC
import struct CryptoKit.SHA256
import struct CryptoKit.SymmetricKey

private let fileHandleChunkSize = 64_000

protocol FileHandleEncrypter {
  func encrypt(_ input: FileHandle, to output: FileHandle) throws
}

protocol FileHandleDecrypter {
  func decrypt(_ input: FileHandle, to output: FileHandle) throws
}

typealias FileHandleEncryptionEngine = FileHandleEncrypter & FileHandleDecrypter

struct AESCBC {
  let aes: EncryptionEngine & StreamEncryptionEngine

  init(key: EncryptedDataKey, initializationVector iv: Data) throws {
    self.aes = try AES.cbc(key: key, initializationVector: iv, padding: .pkcs7)
  }
}

extension AESCBC: EncryptionEngine {
  func encrypt(_ data: Data) throws -> Data {
    return try self.aes.encrypt(data)
  }

  func decrypt(_ data: Data) throws -> Data {
    try self.aes.decrypt(data)
  }
}

extension AESCBC: FileHandleEncryptionEngine {
  func encrypt(_ input: FileHandle, to output: FileHandle) throws {
    let streamEngine = try aes.makeStreamEncrypter()

    while let data = try input.read(upToCount: fileHandleChunkSize) {
      let data = try streamEngine.update(with: data)
      try output.write(contentsOf: data)
    }

    let data = try streamEngine.finalize()
    try output.write(contentsOf: data)
  }

  func decrypt(_ input: FileHandle, to output: FileHandle) throws {
    let streamEngine = try aes.makeStreamDecrypter()

    while let data = try input.read(upToCount: fileHandleChunkSize) {
      let data = try streamEngine.update(with: data)
      try output.write(contentsOf: data)
    }

    let data = try streamEngine.finalize()
    try output.write(contentsOf: data)
  }
}

struct AESCBCHMAC {
  let aes: EncryptionEngine & StreamEncryptionEngine
  let hmacKey: HMACKey
  let initializationVector: Data

  init(key: EncryptedDataKey, hmacKey: HMACKey, initializationVector: Data) throws {
    self.aes = try AES.cbc(
      key: key,
      initializationVector: initializationVector,
      padding: .pkcs7)
    self.hmacKey = hmacKey
    self.initializationVector = initializationVector
  }
}

extension AESCBCHMAC: EncryptionEngine {
  func encrypt(_ data: Data) throws -> Data {
    let encryptedData = try self.aes.encrypt(data)
    return HMAC<SHA256>.authenticationCode(
      for: initializationVector + encryptedData, using: hmacKey) + encryptedData
  }

  func decrypt(_ data: Data) throws -> Data {
    let encryptedDataPosition = data.startIndex + SHA256.byteCount
    let hmac = try data[safe: data.startIndex..<encryptedDataPosition]
    let encryptedData = try data[safe: encryptedDataPosition...]

    guard
      HMAC<SHA256>.isValidAuthenticationCode(
        hmac, authenticating: initializationVector + encryptedData, using: .init(data: hmacKey))
    else {
      throw CryptoEngineError.invalidHMAC
    }

    return try self.aes.decrypt(encryptedData)
  }
}

extension AESCBCHMAC: FileHandleEncryptionEngine {
  func encrypt(_ input: FileHandle, to output: FileHandle) throws {
    let streamEngine = try aes.makeStreamEncrypter()
    var hmac = HMAC<SHA256>(key: hmacKey)
    hmac.update(data: initializationVector)

    let hmacPosition = try output.offset()
    try output.write(contentsOf: Data(repeating: 0, count: SHA256.byteCount))

    while let data = try input.read(upToCount: fileHandleChunkSize), data.count > 0 {
      let encryptedData = try streamEngine.update(with: data)
      hmac.update(data: encryptedData)
      try output.write(contentsOf: encryptedData)
    }

    let encryptedData = try streamEngine.finalize()
    try output.write(contentsOf: encryptedData)
    hmac.update(data: encryptedData)

    let hmacData = hmac.finalize()
    try output.seek(toOffset: hmacPosition)
    try output.write(contentsOf: Data(hmacData))
  }

  func decrypt(_ input: FileHandle, to output: FileHandle) throws {
    let streamEngine = try aes.makeStreamDecrypter()

    let hmacData = try input.read(upToCount: SHA256.byteCount)
    var hmac = HMAC<SHA256>(key: hmacKey)
    hmac.update(data: initializationVector)

    while let encryptedData = try input.read(upToCount: fileHandleChunkSize),
      encryptedData.count > 0
    {
      hmac.update(data: encryptedData)
      let data = try streamEngine.update(with: encryptedData)
      try output.write(contentsOf: data)
    }

    let data = try streamEngine.finalize()
    let expectedHmac = Data(hmac.finalize())

    guard hmacData == expectedHmac else {
      throw CryptoEngineError.invalidHMAC
    }

    try output.write(contentsOf: data)
  }
}
