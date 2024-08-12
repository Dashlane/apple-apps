import CyrilKit
import DashTypes
import Foundation
import SwiftTreats

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

  public let keyAlgorithm: Int

  @OnSync(.lowerCasedKey(current: false, child: true))
  public let privateKey: JWK

  @JSONEncoded
  public var attachments: Set<Attachment>?
  public var spaceId: String?

  @CodingKey("itemName")
  public var title: String
  public var note: String

  @Searchable
  fileprivate var domain: String {
    relyingPartyId.domain?.name ?? relyingPartyId.rawValue
  }

  public init() {
    id = Identifier()
    self.credentialId = Data.random(ofSize: 32).base64EncodedString()
    self.relyingPartyId = PersonalDataURL(rawValue: "")
    self.relyingPartyName = ""
    self.userHandle = ""
    self.userDisplayName = ""
    self.counter = 0
    self.keyAlgorithm = 0
    self.privateKey = JWK(ext: true, keyOps: [], kty: .ecdsa, crv: .p256, d: "", x: "", y: "")
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
    credentialId: String = Data.random(ofSize: 16).base64EncodedString(),
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
    self.keyAlgorithm = keyAlgorithm
    self.privateKey = privateKey
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
