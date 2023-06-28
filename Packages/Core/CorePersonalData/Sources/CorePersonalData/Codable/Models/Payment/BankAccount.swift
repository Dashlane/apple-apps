import Foundation
import DashTypes
import SwiftTreats

public struct BankAccount: PersonalDataCodable, Equatable, Identifiable, DatedPersonalData {
    public static let contentType: PersonalDataContentType = .bankAccount
    public static let searchCategory: SearchCategory = .payment

    enum CodingKeys: String, CodingKey {
        case id
        case anonId
        case metadata
        case bank = "bankAccountBank"
        case bic = "bankAccountBIC"
        case iban = "bankAccountIBAN"
        case name = "bankAccountName"
        case owner = "bankAccountOwner"
        case linkedIdentity
        case country = "localeFormat"
        case creationDatetime
        case userModificationDatetime
        case spaceId
        case attachments
    }

    public let id: Identifier
    public var anonId: String
    public let metadata: RecordMetadata
    public var name: String
    public var bank: BankCodeNamePair?
    public var bic: String
    public var iban: String
    @Linked
    public var linkedIdentity: Identity?
    public var owner: String
    public var country: CountryCodeNamePair?
    public var creationDatetime: Date?
    public var userModificationDatetime: Date?
    public var spaceId: String?
    @JSONEncoded
    public var attachments: Set<Attachment>?

    public init() {
        id = Identifier()
        anonId = UUID().uuidString
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        bank = nil
        bic = ""
        iban = ""
        name = ""
        owner = ""
        _attachments = .init(nil)
        linkedIdentity = nil
        country = CountryCodeNamePair.systemCountryCode
        creationDatetime = Date()
    }

    init(id: Identifier = .init(),
         anonId: String = UUID().uuidString,
         name: String = "",
         bank: BankCodeNamePair? = nil,
         bic: String,
         iban: String,
         owner: String = "",
         country: CountryCodeNamePair? = nil,
         creationDatetime: Date? = nil,
         userModificationDatetime: Date? = nil,
         spaceId: String? = nil) {
        self.id = id
        self.anonId = anonId
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        self.name = name
        self.bank = bank
        self.bic = bic
        self.iban = iban
        self.owner = owner
        self.country = country
        self.creationDatetime = creationDatetime
        self.userModificationDatetime = userModificationDatetime
        self.spaceId = spaceId
        _attachments = .init(nil)
    }

    public func validate() throws {
        if name.isEmptyOrWhitespaces() && bank == nil {
            throw ItemValidationError(invalidProperty: \BankAccount.name)
        } else if bic.isEmptyOrWhitespaces() {
            throw ItemValidationError(invalidProperty: \BankAccount.bic)
        }
    }
}

extension BankAccount: Searchable {
    private var bankName: String {
        return bank?.name ?? ""
    }

    public var searchableKeyPaths: [KeyPath<BankAccount, String>] {
        [
            \BankAccount.owner,
            \BankAccount.bankName
        ]
    }
}

extension BankAccount {
    public var hasBankInformation: Bool {
        guard let code = country?.code else {
            return false
        }
        return ["GB", "US", "FR"].contains(code)
    }
}

extension BankAccount: Deduplicable {

    public var deduplicationKeyPaths: [KeyPath<Self, String>] {
        [
            \BankAccount.iban,
             \BankAccount.bic
        ]
    }
}
