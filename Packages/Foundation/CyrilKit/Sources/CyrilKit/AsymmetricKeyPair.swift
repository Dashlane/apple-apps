import Foundation

public struct AsymmetricKeyPair {
  public enum KeyError: Error {
    public enum CreationFailedReason {
      case cannotParsePEM
      case commonCryptoError
    }

    case keyGenerationFailed(KeyType)
    case keyCreationFailed(CreationFailedReason, type: AsymmetricKeyPair.KeyType)
    case keyConversionFailed
  }

  public enum Algorithm: String {
    case rsa

    var algorithmClass: CFString {
      switch self {
      case .rsa:
        return kSecAttrKeyTypeRSA
      }
    }
  }

  public enum KeyType: String {
    case `public`
    case `private`

    var keyClass: CFString {
      switch self {
      case .public:
        return kSecAttrKeyClassPublic
      case .private:
        return kSecAttrKeyClassPrivate
      }
    }
  }

  public let publicKey: PublicKey
  public let privateKey: PrivateKey

  public init(publicKey: PublicKey, privateKey: PrivateKey) {
    self.publicKey = publicKey
    self.privateKey = privateKey
  }
}

public protocol AsymmetricKey {
  static var type: AsymmetricKeyPair.KeyType { get }

  var secKey: SecKey { get }
  var algorithm: AsymmetricKeyPair.Algorithm { get }

  init(secKey: SecKey, algorithm: AsymmetricKeyPair.Algorithm)
}

public struct PrivateKey: AsymmetricKey {
  public static var type: AsymmetricKeyPair.KeyType = .private

  public let secKey: SecKey
  public let algorithm: AsymmetricKeyPair.Algorithm

  public init(secKey: SecKey, algorithm: AsymmetricKeyPair.Algorithm) {
    self.secKey = secKey
    self.algorithm = algorithm
  }
}

public struct PublicKey: AsymmetricKey {
  public static var type: AsymmetricKeyPair.KeyType = .public

  public let secKey: SecKey
  public let algorithm: AsymmetricKeyPair.Algorithm

  public init(secKey: SecKey, algorithm: AsymmetricKeyPair.Algorithm) {
    self.secKey = secKey
    self.algorithm = algorithm
  }
}

extension AsymmetricKey {
  public func data() throws -> Data {
    return try secKey.data()
  }

  public func pemString() throws -> String {
    var result: [String] = [
      "-----BEGIN \(self.algorithm.rawValue.uppercased()) \(Self.type.rawValue.uppercased()) KEY-----"
    ]
    let characters = try Array(data().base64EncodedString())
    let lineSize = 64
    stride(from: 0, to: characters.count, by: lineSize).forEach { index in
      result.append(String(characters[index..<min(index + lineSize, characters.count)]))
    }
    result.append(
      "-----END \(self.algorithm.rawValue.uppercased()) \(Self.type.rawValue.uppercased()) KEY-----"
    )
    return result.joined(separator: "\n")
  }
}

extension SecKey {
  public func data() throws -> Data {
    var error: Unmanaged<CFError>?
    defer {
      error?.release()
    }

    guard let keyData = SecKeyCopyExternalRepresentation(self, &error) else {
      throw AsymmetricKeyPair.KeyError.keyConversionFailed
    }
    if let error = error {
      error.release()
      throw AsymmetricKeyPair.KeyError.keyConversionFailed
    }

    return keyData as Data
  }
}

extension AsymmetricKey {
  public init(pemString: String, algorithm: AsymmetricKeyPair.Algorithm = .rsa) throws {
    guard let data = Data(pemString: pemString) else {
      throw AsymmetricKeyPair.KeyError.keyCreationFailed(.cannotParsePEM, type: Self.type)
    }

    try self.init(data: data, algorithm: algorithm)
  }

  private init(data: Data, algorithm: AsymmetricKeyPair.Algorithm = .rsa) throws {
    var error: Unmanaged<CFError>?
    defer {
      error?.release()
    }
    let attributes =
      [
        kSecAttrKeyType: algorithm.algorithmClass,
        kSecAttrKeyClass: Self.type.keyClass,
      ] as NSDictionary
    let key = SecKeyCreateWithData((data as NSData), attributes, &error)
    guard error == nil, let key = key else {
      throw AsymmetricKeyPair.KeyError.keyCreationFailed(.commonCryptoError, type: Self.type)
    }

    self.init(secKey: key, algorithm: algorithm)
  }
}

extension Data {
  fileprivate init?(pemString: String) {
    let base64 =
      pemString
      .replacingOccurrences(of: "\r\n", with: "\n")
      .replacingOccurrences(of: "\r", with: "\n")
      .split(separator: "\n")
      .map { $0.trimmingCharacters(in: .whitespaces) }
      .filter { line in
        return !line.hasPrefix("-----BEGIN") && !line.hasPrefix("-----END")
      }
      .joined(separator: "")

    guard let data = Data(base64Encoded: base64, options: .ignoreUnknownCharacters) else {
      return nil
    }

    self = data
  }
}
