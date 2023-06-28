import Foundation
import DashTypes
import SwiftTreats

public struct CreditCard: PersonalDataCodable, Equatable, Identifiable, DatedPersonalData {

    public static let contentType: PersonalDataContentType = .creditCard
    public static let searchCategory: SearchCategory = .payment

    public enum CodingKeys: String, CodingKey {
        case id
        case anonId
        case metadata
        case bank
        case cardNumber
        case note = "cCNote"
        case color
        case expireMonth
        case expireYear
        case issueNumber
        case linkedBillingAddress
        case name
        case ownerName
        case securityCode
        case startMonth
        case startYear
        case country = "localeFormat"
        case creationDatetime
        case userModificationDatetime
        case type
        case spaceId
        case attachments
    }

    public let id: Identifier
    public var anonId: String
    public let metadata: RecordMetadata
    public var bank: BankCodeNamePair?
    public var cardNumber: String {
        didSet {
            type = CreditCardType(cardNumber: cardNumber)
        }
    }
    public var securityCode: String 

    public var name: String
    public var color: CreditCardColor
    public var note: String

    public var issueNumber: String 
    public var linkedBillingAddress: Identifier?
    public var ownerName: String

    public var startMonth: Int? 
    public var startYear: Int? 
    public var expireMonth: Int?
    public var expireYear: Int?

    public var country: CountryCodeNamePair?
    public var creationDatetime: Date?
    public var userModificationDatetime: Date?
    public var spaceId: String?
    public private(set) var type: CreditCardType?
    @JSONEncoded
    public var attachments: Set<Attachment>?

    public var cardNumberLastDigits: String? {
        return String(cardNumber.suffix(4))
    }

                mutating func link(with address: Address) {
        self.linkedBillingAddress = address.id
    }

            public init() {
        id = Identifier()
        anonId = UUID().uuidString
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        bank = nil
        cardNumber = ""
        note = ""
        color = .defaultValue
        expireMonth = nil
        expireYear = nil
        issueNumber = ""
        linkedBillingAddress = nil
        name = ""
        ownerName = ""
        securityCode = ""
        startMonth = nil
        startYear = nil
        country = CountryCodeNamePair.systemCountryCode
        creationDatetime = Date()
        _attachments = .init(nil)
    }

    init(id: Identifier = .init(),
         anonId: String = UUID().uuidString,
         bank: BankCodeNamePair? = nil,
         cardNumber: String,
         securityCode: String,
         name: String = "",
         color: CreditCardColor = .defaultValue,
         note: String = "",
         issueNumber: String = "",
         linkedBillingAddress:
            Identifier? = nil,
         ownerName: String = "",
         startMonth: Int? = nil,
         startYear: Int? = nil,
         expireMonth: Int? = nil,
         expireYear: Int? = nil,
         country: CountryCodeNamePair? = nil,
         creationDatetime: Date? = nil,
         userModificationDatetime: Date? = nil,
         spaceId: String? = nil,
         type: CreditCardType? = nil) {
        self.id = id
        self.anonId = anonId
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        self.bank = bank
        self.cardNumber = cardNumber
        self.note = note
        self.color = color
        self.expireMonth = expireMonth
        self.expireYear = expireYear
        self.issueNumber = issueNumber
        self.linkedBillingAddress = linkedBillingAddress
        self.name = name
        self.ownerName = ownerName
        self.spaceId = spaceId
        self.securityCode = securityCode
        self.startMonth = startMonth
        self.startYear = startYear
        self.country = country
        self.creationDatetime = creationDatetime
        self.userModificationDatetime = userModificationDatetime
        self.type = type
        _attachments = .init(nil)
    }

    public func validate() throws {
        if name.isEmptyOrWhitespaces() && bank == nil {
            throw ItemValidationError(invalidProperty: \CreditCard.name)
        } else if cardNumber.isEmptyOrWhitespaces() {
            throw ItemValidationError(invalidProperty: \CreditCard.cardNumber)
        }
    }
}

extension CreditCard: Searchable {
    public var searchableKeyPaths: [KeyPath<CreditCard, String>] {
        return [
            \CreditCard.name,
            \CreditCard.ownerName
        ]
    }
}

extension CreditCard: Deduplicable {

    public var deduplicationKeyPaths: [KeyPath<Self, String>] {
        [
            \CreditCard.cardNumber,
             \CreditCard.securityCode,
             \CreditCard.note
        ]
    }
}
