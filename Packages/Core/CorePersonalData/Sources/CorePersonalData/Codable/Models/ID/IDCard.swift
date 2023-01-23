import Foundation
import DashTypes
import SwiftTreats

public struct IDCard: PersonalDataCodable, Equatable, Identifiable, IdentityLinked, DatedPersonalData {
    public static let contentType: PersonalDataContentType = .idCard
    public static let searchCategory: SearchCategory = .id

    enum CodingKeys: String, CodingKey {
        case id
        case anonId
        case metadata
        case fullName = "fullname"
        case dateOfBirth
        case deliveryDate
        case expireDate
        case number
        case creationDatetime
        case sex
        case spaceId
        case attachments
        case userModificationDatetime
        case nationality = "localeFormat"
        case linkedIdentity
    }
    
    public enum Mode {
        case hongKong
        case france
        case other
    }
    
    public var id: Identifier
    public let metadata: RecordMetadata
    public var anonId: String
    public var number: String
    @CalendarDateFormatted
    public var dateOfBirth: Date?
    @CalendarDateFormatted
    public var deliveryDate: Date?
    @CalendarDateFormatted
    public var expireDate: Date?
    @Linked
    public var linkedIdentity: Identity?
    public var fullName: String
    public var sex: Gender?
    public var nationality: CountryCodeNamePair?
    public var creationDatetime: Date?
    public var userModificationDatetime: Date?
    public var spaceId: String?
    @JSONEncoded
    public var attachments: Set<Attachment>?

    public var mode: Mode {
        guard let nationality = self.nationality ?? CountryCodeNamePair.systemCountryCode else {
            return .other
        }
        return nationality.idCardMode
    }
    
    public init() {
        id = Identifier()
        _attachments = .init(nil)
        anonId = UUID().uuidString
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        fullName = ""
        number = ""
        dateOfBirth = nil
        deliveryDate = nil
        expireDate = nil
        creationDatetime = Date()
        nationality = CountryCodeNamePair.systemCountryCode
    }
    
    init(id: Identifier,
         anonId: String,
         number: String,
         dateOfBirth: String?,
         deliveryDate: String?,
         expireDate: String?,
         linkedIdentity: Identifier?,
         fullName: String,
         sex: Gender? = nil,
         nationality: CountryCodeNamePair? = nil,
         creationDatetime: Date? = nil,
         userModificationDatetime: Date? = nil,
         spaceId: String? = nil) {
        self.id = id
        self.anonId = anonId
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        self.number = number
        self._dateOfBirth = CalendarDateFormatted(rawValue: dateOfBirth)
        self._deliveryDate = CalendarDateFormatted(rawValue: deliveryDate)
        self._expireDate = CalendarDateFormatted(rawValue: expireDate)
        self._linkedIdentity = Linked(identifier: linkedIdentity)
        self.fullName = fullName
        self.sex = sex
        self.nationality = nationality
        self.creationDatetime = creationDatetime
        self.userModificationDatetime = userModificationDatetime
        self.spaceId = spaceId
        _attachments = .init(nil)
    }
}

extension IDCard {
    public func validate() throws {
        if fullName.isEmptyOrWhitespaces() && number.isEmptyOrWhitespaces() {
            let invalidProperty = fullName.isEmptyOrWhitespaces() ? \IDCard.fullName : \.number
            throw ItemValidationError(invalidProperty: invalidProperty)
        }
    }
}

extension IDCard: Searchable {
    public var searchableKeyPaths: [KeyPath<IDCard, String>] {
        return [
            \.displayFullName,
            \.number,
            \.linkedIdentitySearchValue
        ]
    }
}

extension IDCard {
    public var displayFullName: String {
        return linkedIdentityFullName ?? fullName
    }
}

extension CountryCodeNamePair {
    var idCardMode: IDCard.Mode {
        if ["HK"].contains(code) {
            return .hongKong
        } else if ["FR"].contains(code) {
            return .france
        }
        return .other
    }
}
