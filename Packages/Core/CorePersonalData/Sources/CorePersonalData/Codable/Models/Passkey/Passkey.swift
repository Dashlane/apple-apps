import CoreTypes
import CyrilKit
import DashlaneAPI
import Foundation
import LogFoundation
import SwiftTreats

@Loggable
@PersonalData
public struct Passkey: Equatable, Identifiable, DatedPersonalData {

  public typealias CredentialId = String

  public static let searchCategory: SearchCategory = .credential

  public var creationDatetime: Date?
  public var userModificationDatetime: Date?

  public let credentialId: CredentialId

  @CodingKey("rpId")
  public let relyingPartyId: PersonalDataURL

  @Searchable
  @CodingKey("rpName")
  public let relyingPartyName: String

  public let userHandle: String

  public let userDisplayName: String

  public let counter: Int

  public let keyAlgorithm: KeyAlgorithm

  @CodingKey("privateKey")
  @OnSync(.lowerCasedKey(current: false, child: true))
  public let localPrivateKey: JWK?

  public let cloudPasskey: CloudPasskey?

  @JSONEncoded
  public var attachments: Set<Attachment>?
  public var spaceId: String?

  @CodingKey("itemName")
  public var title: String
  public var note: String

  @Searchable
  public var domain: String {
    relyingPartyId.domain?.name ?? relyingPartyId.rawValue
  }

  public init() {
    id = Identifier()
    self.credentialId = Passkey.makeCredentialIdBase64URLEncoded()
    self.relyingPartyId = PersonalDataURL(rawValue: "")
    self.relyingPartyName = ""
    self.userHandle = ""
    self.userDisplayName = ""
    self.counter = 0
    self.keyAlgorithm = .local(0)
    self.localPrivateKey = nil
    self.cloudPasskey = nil
    self.metadata = RecordMetadata(
      id: .temporary,
      contentType: .passkey,
      syncStatus: nil,
      isShared: false,
      sharingPermission: nil)
    self.title = ""
    self.note = ""
    _attachments = .init(nil)
  }

  public init(
    id: Identifier = .init(),
    creationDatetime: Date = Date.now,
    userModificationDatetime: Date? = nil,
    title: String = "",
    note: String = "",
    credentialId: String = Passkey.makeCredentialIdBase64URLEncoded(),
    relyingPartyId: String,
    relyingPartyName: String,
    userHandle: String,
    userDisplayName: String,
    counter: Int,
    keyAlgorithm: Int,
    privateKey: JWK,
    lastLocalUseDate: Date? = nil,
    attachments: Set<Attachment>? = nil,
    spaceId: String? = nil
  ) {
    self.id = id
    self.metadata = RecordMetadata(
      id: .temporary,
      contentType: .passkey,
      syncStatus: nil,
      isShared: false,
      sharingPermission: nil,
      lastLocalUseDate: lastLocalUseDate)
    self.creationDatetime = creationDatetime
    self.userModificationDatetime = userModificationDatetime
    self.credentialId = credentialId
    self.relyingPartyId = PersonalDataURL(rawValue: relyingPartyId)
    self.relyingPartyName = relyingPartyName
    self.userHandle = userHandle
    self.userDisplayName = userDisplayName
    self.counter = counter
    self.keyAlgorithm = .local(keyAlgorithm)
    self.localPrivateKey = privateKey
    self.cloudPasskey = nil
    _attachments = .init(attachments)
    self.spaceId = spaceId
    self.title = title
    self.note = note
  }

  public init(
    id: Identifier = .init(),
    creationDatetime: Date = Date.now,
    userModificationDatetime: Date? = nil,
    title: String = "",
    note: String = "",
    credentialId: String,
    relyingPartyId: String,
    relyingPartyName: String,
    userHandle: String,
    userDisplayName: String,
    counter: Int,
    cloudPasskey: CloudPasskey,
    lastLocalUseDate: Date? = nil,
    attachments: Set<Attachment>? = nil,
    spaceId: String? = nil
  ) {
    self.id = id
    self.metadata = RecordMetadata(
      id: .temporary,
      contentType: .passkey,
      syncStatus: nil,
      isShared: false,
      sharingPermission: nil,
      lastLocalUseDate: lastLocalUseDate)
    self.creationDatetime = creationDatetime
    self.userModificationDatetime = userModificationDatetime
    self.credentialId = credentialId
    self.relyingPartyId = PersonalDataURL(rawValue: relyingPartyId)
    self.relyingPartyName = relyingPartyName
    self.userHandle = userHandle
    self.userDisplayName = userDisplayName
    self.counter = counter
    self.keyAlgorithm = .cloud
    self.localPrivateKey = nil
    self.cloudPasskey = cloudPasskey
    _attachments = .init(attachments)
    self.spaceId = spaceId
    self.title = title
    self.note = note
  }

  public mutating func prepareForSaving() {
    if title.isEmpty {
      title = relyingPartyName
    }
  }
}

extension Passkey {
  public enum Mode {
    case cloud(CloudPasskey)
    case local(JWK)
  }

  public enum PasskeyError: Error, LocalizedError {
    case invalidCloudPasskey
    case invalidLocalPasskey

    public var errorDescription: String? {
      switch self {
      case .invalidCloudPasskey:
        "Invalid cloud passkey, missing cloud passkey"
      case .invalidLocalPasskey:
        "Invalid local passkey, missing localPrivateKey"
      }
    }
  }

  public enum KeyAlgorithm: Codable, Equatable {
    public static let cloudKey = -65537
    case cloud
    case local(Int)

    public init(from decoder: any Decoder) throws {
      let container = try decoder.singleValueContainer()
      let algorithmValue: Int = try container.decode(Int.self)
      if algorithmValue == KeyAlgorithm.cloudKey {
        self = .cloud
      } else {
        self = .local(algorithmValue)
      }
    }

    public func encode(to encoder: any Encoder) throws {
      var container = encoder.singleValueContainer()
      switch self {
      case .cloud:
        try container.encode(KeyAlgorithm.cloudKey)
      case .local(let value):
        try container.encode(value)
      }
    }
  }

  public struct CloudPasskey: Codable, Equatable {
    public let passkeyId: String
    public let passkeyEncryptionKey: String
    public let passkeyEncryptionKeyId: String

    public init(passkeyId: String, passkeyEncryptionKey: String, passkeyEncryptionKeyId: String) {
      self.passkeyId = passkeyId
      self.passkeyEncryptionKey = passkeyEncryptionKey
      self.passkeyEncryptionKeyId = passkeyEncryptionKeyId
    }
  }

  public var mode: Mode {
    get throws {
      switch keyAlgorithm {
      case .cloud:
        guard let cloudPasskey else {
          throw PasskeyError.invalidCloudPasskey
        }

        return .cloud(cloudPasskey)
      case .local:
        guard let localPrivateKey else {
          throw PasskeyError.invalidLocalPasskey
        }

        return .local(localPrivateKey)
      }
    }
  }
}

extension Passkey.CloudPasskey {
  public var encryptionKey: PasskeysPasskeyEncryptionKey {
    return PasskeysPasskeyEncryptionKey(uuid: passkeyEncryptionKeyId, key: passkeyEncryptionKey)
  }

  public init(passkeyId: String, encryptionKey: PasskeysPasskeyEncryptionKey) {
    self.passkeyId = passkeyId
    self.passkeyEncryptionKey = encryptionKey.key
    self.passkeyEncryptionKeyId = encryptionKey.uuid
  }
}

extension Passkey {
  public static func makeCredentialId() -> Data {
    Data.random(ofSize: 16)
  }

  public static func makeCredentialIdBase64URLEncoded() -> String {
    makeCredentialId().base64URLEncoded()
  }
}

extension Passkey: Displayable {
  public var displayTitle: String {
    if title.isEmpty {
      return relyingPartyName
    }
    return title
  }
  public var displaySubtitle: String? {
    return "Passkey"
  }
}
