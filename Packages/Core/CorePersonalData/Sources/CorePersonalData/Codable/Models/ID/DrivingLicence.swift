import Foundation
import DashTypes
import SwiftTreats

public struct DrivingLicence: PersonalDataCodable, Equatable, Identifiable, IdentityLinked, DatedPersonalData {

    public static let contentType: PersonalDataContentType = .driverLicence
    public static let searchCategory: SearchCategory = .id

    enum CodingKeys: String, CodingKey {
        case id
        case anonId
        case metadata
        case deliveryDate
        case expireDate
        case fullname
        case linkedIdentity
        case number
        case sex
        case state
        case country = "localeFormat"
        case creationDatetime
        case userModificationDatetime
        case spaceId
        case attachments
    }

    public enum Mode {
        case countryWithState
        case other
    }

    public var id: Identifier
    public let metadata: RecordMetadata
    public var anonId: String
    public var number: String
    @CalendarDateFormatted
    public var deliveryDate: Date?
    @CalendarDateFormatted
    public var expireDate: Date?
    @Linked
    public var linkedIdentity: Identity?
    public var fullname: String
    public var sex: Gender?
    public var state: StateCodeNamePair?
    public var country: CountryCodeNamePair?
    public var creationDatetime: Date?
    public var userModificationDatetime: Date?
    public var spaceId: String?
    @JSONEncoded
    public var attachments: Set<Attachment>?

    public var mode: Mode {
        guard let country = self.country ?? CountryCodeNamePair.systemCountryCode else {
            return .other
        }
        return country.drivingLicenceMode
    }

    public init() {
        id = Identifier()
        anonId = UUID().uuidString
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        fullname = ""
        number = ""
        country = CountryCodeNamePair.systemCountryCode
        creationDatetime = Date()
        _attachments = .init(nil)
    }

    init(id: Identifier,
         anonId: String,
         number: String,
         deliveryDate: String?,
         expireDate: String?,
         linkedIdentity: Identifier?,
         fullname: String,
         sex: Gender? = nil,
         state: StateCodeNamePair? = nil,
         country: CountryCodeNamePair? = nil,
         creationDatetime: Date? = nil,
         userModificationDatetime: Date? = nil,
         spaceId: String? = nil) {
        self.id = id
        self.anonId = anonId
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        self.number = number
        self._deliveryDate = CalendarDateFormatted(rawValue: deliveryDate)
        self._expireDate = CalendarDateFormatted(rawValue: expireDate)
        self._linkedIdentity = .init(identifier: linkedIdentity)
        self.fullname = fullname
        self.sex = sex
        self.state = state
        self.country = country
        self.creationDatetime = creationDatetime
        self.userModificationDatetime = userModificationDatetime
        self.spaceId = spaceId
        _attachments = .init(nil)
    }

}

extension DrivingLicence {
    public func validate() throws {
        if fullname.isEmptyOrWhitespaces() && number.isEmptyOrWhitespaces() {
            let invalidProperty = fullname.isEmptyOrWhitespaces() ? \DrivingLicence.fullname : \.number
            throw ItemValidationError(invalidProperty: invalidProperty)
        }
    }
}

extension DrivingLicence: Searchable {
    public var searchableKeyPaths: [KeyPath<DrivingLicence, String>] {
        return [
            \.displayFullName,
            \.linkedIdentitySearchValue
        ]
    }
}

extension CountryCodeNamePair {
    var drivingLicenceMode: DrivingLicence.Mode {
        switch code {
            case "US", "CA", "AU": return .countryWithState
            default: return .other
        }
    }
}

public extension DrivingLicence {
    var displayFullName: String {
        return linkedIdentityFullName ?? fullname
    }
}
