import Foundation
import SwiftTreats
import DashTypes

public struct Phone: PersonalDataCodable, Equatable, Identifiable, Hashable, DatedPersonalData {
    public static let contentType: PersonalDataContentType = .phone
    public static let searchCategory: SearchCategory = .personalInfo

    public enum CodingKeys: String, CodingKey {
        case id
        case anonId
        case metadata
        case name = "phoneName"
        case number
        case nationalNumber = "numberNational"
        case interNationalNumber = "numberInternational"
        case type
        case country = "localeFormat"
        case creationDatetime
        case spaceId
        case attachments
        case userModificationDatetime
    }

    public enum NumberType: String, Codable, Defaultable, CaseIterable, Identifiable {
        public static let defaultValue: NumberType = .none
        public var id: String {
            return self.rawValue
        }

        case mobile = "PHONE_TYPE_MOBILE"
        case fax = "PHONE_TYPE_FAX"
        case landline = "PHONE_TYPE_LANDLINE"
        case workMobile = "PHONE_TYPE_WORK_MOBILE"
        case workLandline = "PHONE_TYPE_WORK_LANDLINE"
        case workFax = "PHONE_TYPE_WORK_FAX"
        case none = "PHONE_TYPE_ANY"
    }

    public let id: Identifier
    public var anonId: String
    public let metadata: RecordMetadata
    public var name: String
    public var number: String
    public var nationalNumber: String
    public var interNationalNumber: String
    public var type: NumberType?
    public var country: CountryCodeNamePair?
    public var creationDatetime: Date?
    public var userModificationDatetime: Date?
    public var spaceId: String?
    @JSONEncoded
    public var attachments: Set<Attachment>?

    public init() {
        id = Identifier()
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        anonId = UUID().uuidString
        number = ""
        name = ""
        creationDatetime = Date()
        userModificationDatetime = nil
        nationalNumber = ""
        interNationalNumber = ""
        type = .mobile
        country = nil
        _attachments = .init(nil)
    }

    init(id: Identifier,
         anonId: String,
         name: String,
         number: String,
         nationalNumber: String,
         interNationalNumber: String,
         type: Phone.NumberType? = nil,
         country: CountryCodeNamePair? = nil,
         creationDatetime: Date? = nil,
         userModificationDatetime: Date? = nil,
         spaceId: String? = nil) {
        self.id = id
        self.anonId = anonId
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        self.name = name
        self.number = number
        self.creationDatetime = creationDatetime
        self.userModificationDatetime = userModificationDatetime
        self.nationalNumber = nationalNumber
        self.interNationalNumber = interNationalNumber
        self.type = type
        self.country = country
        self.spaceId = spaceId
        _attachments = .init(nil)
    }

    public func validate() throws {
        if number.isEmptyOrWhitespaces() {
            throw ItemValidationError(invalidProperty: \Phone.number)
        }
    }
}

extension Phone: Searchable {

    public var searchableKeyPaths: [KeyPath<Phone, String>] {
        let keyPathsList: [KeyPath<Phone, String>] = [
            \Phone.name,
            \Phone.number,
            \Phone.nationalNumber,
            \Phone.interNationalNumber
        ]
        return keyPathsList
    }
}
