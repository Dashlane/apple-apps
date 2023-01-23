import Foundation
import DashTypes
import SwiftTreats

public struct SocialSecurityInformation: PersonalDataCodable, Equatable, Identifiable, IdentityLinked, DatedPersonalData {
    public static let contentType: PersonalDataContentType = .socialSecurityInfo
    public static let searchCategory: SearchCategory = .personalInfo

    enum CodingKeys: String, CodingKey {
        case id
        case anonId
        case metadata
        case country = "localeFormat"
        case linkedIdentity
        case dateOfBirth
        case sex
        case fullname = "socialSecurityFullname"
        case number = "socialSecurityNumber"
        case creationDatetime
        case userModificationDatetime
        case spaceId
        case attachments
    }

    public enum Mode {
          case us
          case france
          case uk
          case other
      }
      
    
    public let id: Identifier
    public var anonId: String
    public let metadata: RecordMetadata
    public var number: String
    public var country: CountryCodeNamePair?
    @CalendarDateFormatted
    public var dateOfBirth: Date?
    @Linked
    public var linkedIdentity: Identity?
    public var fullname: String
    public var sex: Gender?
    public var creationDatetime: Date?
    public var userModificationDatetime: Date?
    public var spaceId: String?
    @JSONEncoded
    public var attachments: Set<Attachment>?

    public var mode: Mode {
         guard let country = self.country ?? CountryCodeNamePair.systemCountryCode else {
             return .other
         }
         return country.socialSecurityCardMode
     }
    
    public init() {
        id = Identifier()
        anonId = UUID().uuidString
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        country = CountryCodeNamePair.systemCountryCode
        fullname = ""
        number = ""
        sex = .male
        creationDatetime = Date()
        userModificationDatetime = nil
        _attachments = .init(nil)
    }
    
    init(id: Identifier,
         anonId: String,
         number: String,
         country: CountryCodeNamePair? = nil,
         dateOfBirth: String?, 
         linkedIdentity: Identifier?,
         fullname: String, sex: Gender? = nil,
         creationDatetime: Date? = nil,
         userModificationDatetime: Date? = nil,
         spaceId: String? = nil) {
        self.id = id
        self.anonId = anonId
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        self.number = number
        self.country = country
        self._dateOfBirth = CalendarDateFormatted(rawValue: dateOfBirth)
        self._linkedIdentity = Linked(identifier: linkedIdentity)
        self.fullname = fullname
        self.sex = sex
        self.creationDatetime = creationDatetime
        self.userModificationDatetime = userModificationDatetime
        self.spaceId = spaceId
        _attachments = .init(nil)
    }
}

extension SocialSecurityInformation {
    public func validate() throws {
        if fullname.isEmptyOrWhitespaces() && number.isEmptyOrWhitespaces() {
            let invalidProperty = fullname.isEmptyOrWhitespaces() ? \SocialSecurityInformation.fullname : \.number
            throw ItemValidationError(invalidProperty: invalidProperty)
        }
    }
}

extension SocialSecurityInformation: Searchable {
    public var searchableKeyPaths: [KeyPath<SocialSecurityInformation, String>] {
        return [
            \.displayFullName,
            \.linkedIdentitySearchValue
        ]
    }
}

extension SocialSecurityInformation {
    public var displayFullName: String {
        return linkedIdentityFullName ?? fullname
    }
}

extension CountryCodeNamePair {
    var socialSecurityCardMode: SocialSecurityInformation.Mode {
        if ["US"].contains(code) {
            return .us
        } else if ["FR"].contains(code) {
            return .france
        } else if ["GB"].contains(code) {
            return .uk
        }
        return .other
    }
}
