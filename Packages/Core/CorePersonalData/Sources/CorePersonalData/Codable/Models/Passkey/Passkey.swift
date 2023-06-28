import Foundation

import DashTypes
import SwiftTreats
import CyrilKit

public struct Passkey: PersonalDataCodable, Equatable, Identifiable, DatedPersonalData {
    public static let contentType: PersonalDataContentType = .passkey
    public static let searchCategory: SearchCategory = .credential
    public static var xmlRuleExceptions: [String : XMLRuleException] {
        [CodingKeys.privateKey.rawValue: .lowerCasedKey(current: false, child: true)]
    }

    public enum CodingKeys: String, CodingKey {
                case id
        case anonId
        case metadata

                case creationDatetime
        case userModificationDatetime

                case credentialId
        case relyingPartyId = "rpId"
        case relyingPartyName = "rpName"
        case userHandle
        case userDisplayName
        case counter
        case keyAlgorithm
        case privateKey

                case attachments
        case spaceId
        case title
        case note
    }

        public let id: Identifier
    public var anonId: String
    public var metadata: RecordMetadata

        public var creationDatetime: Date?
    public var userModificationDatetime: Date?

            public let credentialId: String

        public let relyingPartyId: String

        public let relyingPartyName: String

        public let userHandle: String

        public let userDisplayName: String

        public let counter: Int

        public let keyAlgorithm: Int

        public let privateKey: WebAuthnPrivateKey

        public var attachments: Set<Attachment>?
    public var spaceId: String?
    public var title: String
    public var note: String

            public init() {
        id = Identifier()
        anonId = UUID().uuidString
        self.credentialId = Data.random(ofSize: 32).base64EncodedString()
        self.relyingPartyId = ""
        self.relyingPartyName = ""
        self.userHandle = ""
        self.userDisplayName = ""
        self.counter = 0
        self.keyAlgorithm = 0
        self.privateKey = WebAuthnPrivateKey(ext: true, keyOps: [], kty: "", crv: "", d: "", x: "", y: "")
        self.metadata = RecordMetadata(id: .temporary,
                                       contentType: .passkey,
                                       syncStatus: nil,
                                       isShared: false,
                                       sharingPermission: nil)
        self.title = ""
        self.note = ""
    }

    public init(id: Identifier = .init(),
                anonId: String = UUID().uuidString,
                creationDatetime: Date = Date.now,
                userModificationDatetime: Date? = nil,
                title: String = "",
                note: String = "",
                credentialId: String = Data.random(ofSize: 32).base64EncodedString(),
                relyingPartyId: String,
                relyingPartyName: String,
                userHandle: String,
                userDisplayName: String,
                counter: Int,
                keyAlgorithm: Int,
                privateKey: WebAuthnPrivateKey,
                attachments: Set<Attachment>? = nil,
                spaceId: String? = nil) {
        self.id = id
        self.anonId = anonId
        self.metadata = RecordMetadata(id: .temporary,
                                       contentType: .passkey,
                                       syncStatus: nil,
                                       isShared: false,
                                       sharingPermission: nil)
        self.creationDatetime = creationDatetime
        self.userModificationDatetime = userModificationDatetime
        self.credentialId = credentialId
        self.relyingPartyId = relyingPartyId
        self.relyingPartyName = relyingPartyName
        self.userHandle = userHandle
        self.userDisplayName = userDisplayName
        self.counter = counter
        self.keyAlgorithm = keyAlgorithm
        self.privateKey = privateKey
        self.attachments = attachments
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

public struct WebAuthnPrivateKey: Codable, Equatable {
        public let ext: Bool
        public let keyOps: [String]
        public let kty: String
        public let crv: String

    public let d: String
    public let x: String
    public let y: String

    enum CodingKeys: String, CodingKey {
        case ext
        case keyOps = "key_ops"
        case d
        case x
        case kty
        case y
        case crv
    }

    public init(ext: Bool,
                keyOps: [String],
                kty: String,
                crv: String,
                d: String,
                x: String,
                y: String) {
        self.ext = ext
        self.keyOps = keyOps
        self.kty = kty
        self.crv = crv
        self.d = d
        self.x = x
        self.y = y
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

extension Passkey: Searchable {

    public var searchableKeyPaths: [KeyPath<Passkey, String>] {
        return [
            \Passkey.relyingPartyName,
             \Passkey.relyingPartyId,
             \Passkey.title
        ]
    }
}
