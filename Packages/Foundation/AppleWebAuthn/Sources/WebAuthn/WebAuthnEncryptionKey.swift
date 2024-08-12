import CryptoKit
import Foundation
import SwiftCBOR

public struct WebAuthnEncryptionKey {

  public enum PrivateKey {
    case es256(P256.Signing.PrivateKey)
    case es384(P384.Signing.PrivateKey)
    case es512(P521.Signing.PrivateKey)
  }

  public let algorithm: COSEAlgorithmIdentifier
  public let privateKey: PrivateKey

  public init(privateKey: PrivateKey) {
    self.algorithm = privateKey.algorithm
    self.privateKey = privateKey
  }

  public init(algorithm: COSEAlgorithmIdentifier) {
    self.algorithm = algorithm
    switch algorithm {
    case .es256:
      self.privateKey = .es256(P256.Signing.PrivateKey())
    case .es384:
      self.privateKey = .es384(P384.Signing.PrivateKey())
    case .es512:
      self.privateKey = .es512(P521.Signing.PrivateKey())
    }
  }

  public func signature(for digest: Data) throws -> Data {
    switch privateKey {
    case let .es256(privateKey):
      return try privateKey.signature(for: digest).derRepresentation
    case let .es384(privateKey):
      return try privateKey.signature(for: digest).derRepresentation
    case let .es512(privateKey):
      return try privateKey.signature(for: digest).derRepresentation
    }
  }

}

extension WebAuthnEncryptionKey.PrivateKey {
  public var algorithm: COSEAlgorithmIdentifier {
    switch self {
    case .es256:
      return .es256
    case .es384:
      return .es384
    case .es512:
      return .es512
    }
  }

  public var ec2PublicKey: EC2PublicKey {
    switch self {
    case let .es256(privateKey):
      let coordinates = privateKey.publicKey.coordinates
      return EC2PublicKey(
        algorithm: .es256,
        curve: .p256,
        xCoordinate: coordinates.x,
        yCoordinate: coordinates.y)
    case let .es384(privateKey):
      let coordinates = privateKey.publicKey.coordinates
      return EC2PublicKey(
        algorithm: .es384,
        curve: .p384,
        xCoordinate: coordinates.x,
        yCoordinate: coordinates.y)
    case let .es512(privateKey):
      let coordinates = privateKey.publicKey.coordinates
      return EC2PublicKey(
        algorithm: .es512,
        curve: .p521,
        xCoordinate: coordinates.x,
        yCoordinate: coordinates.y)
    }
  }
}
