import CoreTypes
import Foundation
import LogFoundation
import SwiftTreats

@Loggable
@PersonalData
public struct WiFi: Equatable, Identifiable, DatedPersonalData {
  public static let searchCategory: SearchCategory = .credential

  public enum EncryptionType: String, Codable, Defaultable, CaseIterable, Identifiable {
    public static let defaultValue: EncryptionType = .unsecured
    public var id: String {
      return self.rawValue
    }

    case unsecured
    case wpapersonal = "wpa-personal"
    case wpa2Personal = "wpa2-personal"
    case wpa3Personal = "wpa3-personal"
    case wep
  }

  public var spaceId: String?
  @Searchable
  public var ssid: String
  public var encryptionType: EncryptionType
  public var passphrase: String
  public var hidden: Bool
  @Searchable
  public var name: String
  public var note: String
  public var creationDatetime: Date?
  public var userModificationDatetime: Date?
  @JSONEncoded
  public var attachments: Set<Attachment>?

  public init() {
    id = Identifier()
    metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
    ssid = ""
    encryptionType = .unsecured
    passphrase = ""
    hidden = false
    name = ""
    note = ""
    creationDatetime = Date()
    _attachments = .init(nil)
  }

  public init(
    id: Identifier = .init(),
    ssid: String,
    encryptionType: EncryptionType,
    passphrase: String = "",
    hidden: Bool = false,
    name: String = "",
    note: String = "",
    creationDatetime: Date? = nil,
    userModificationDatetime: Date? = nil
  ) {
    self.id = id
    _attachments = .init(nil)
    metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
    self.ssid = ssid
    self.encryptionType = encryptionType
    self.passphrase = passphrase
    self.hidden = hidden
    self.name = name
    self.note = note
    self.creationDatetime = creationDatetime
    self.userModificationDatetime = userModificationDatetime
  }

  public func validate() throws {
    if ssid.isEmptyOrWhitespaces() {
      throw ItemValidationError(invalidProperty: \WiFi.ssid)
    }
  }
}

extension WiFi: Deduplicable {
  public var deduplicationKeyPaths: [KeyPath<Self, String>] {
    [
      \WiFi.ssid
    ]
  }
}

extension WiFi: Displayable {
  public var displayTitle: String {
    return name.isEmptyOrWhitespaces() ? ssid : name
  }
  public var displaySubtitle: String? {
    return nil
  }
}
