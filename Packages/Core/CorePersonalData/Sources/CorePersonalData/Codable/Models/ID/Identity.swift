import Foundation
import SwiftTreats
import DashTypes
import SwiftTreats

public struct Identity: PersonalDataCodable, Equatable, Identifiable, DatedPersonalData {
    public static let contentType: PersonalDataContentType = .identity
    public static let searchCategory: SearchCategory = .id

    public enum CodingKeys: String, CodingKey {
        case id
        case anonId
        case metadata
        case personalTitle = "title"
        case firstName
        case middleName
        case lastName
        case lastName2
        case pseudo
        case birthDate
        case birthPlace
        case creationDatetime
        case userModificationDatetime
        case spaceId
        case attachments
        case nationality = "localeFormat"
    }

    public enum Mode {
        case european
        case northAmerican
        case spanish
        case japanese
    }

    public enum PersonalTitle : String, Codable, Defaultable, CaseIterable, Identifiable {
        public static let defaultValue: PersonalTitle = .noneOfThese

        public var id: String {
            return self.rawValue
        }
        
        case mr = "MR"
        case mrs = "MME"
        case miss = "MLLE"
        case ms = "MS"
        case mx = "MX"
        case noneOfThese = "NONE_OF_THESE"
    }

    public let id: Identifier
    public var anonId: String
    public let metadata: RecordMetadata
    @Defaulted
    public var personalTitle: PersonalTitle
    public var firstName: String
    public var middleName: String
    public var lastName: String
    public var lastName2: String
    public var pseudo: String
    @CalendarDateFormatted
    public var birthDate: Date?
    public var birthPlace: String
    public var nationality: CountryCodeNamePair?
    public var creationDatetime: Date?
    public var userModificationDatetime: Date?
    public var spaceId: String?
    @JSONEncoded
    public var attachments: Set<Attachment>?

    public var mode: Mode {
        guard let nationality = self.nationality ?? CountryCodeNamePair.systemCountryCode else {
            return .northAmerican
        }
        return nationality.identityMode
    }

    public init() {
        id = Identifier()
        anonId = UUID().uuidString
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        _personalTitle = .init(.mr)
        firstName = ""
        middleName = ""
        lastName = ""
        lastName2 = ""
        pseudo = ""
        birthPlace = ""
        nationality = CountryCodeNamePair.systemCountryCode
        creationDatetime = Date()
        _attachments = .init(nil)
    }
    
    init(id: Identifier,
         anonId: String,
         personalTitle: Identity.PersonalTitle,
         firstName: String,
         middleName: String,
         lastName: String,
         lastName2: String,
         pseudo: String,
         birthDate: String?,
         birthPlace: String,
         nationality: CountryCodeNamePair? = nil,
         creationDatetime: Date? = nil,
         userModificationDatetime: Date? = nil,
         spaceId: String? = nil) {
        self.id = id
        self.anonId = anonId
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        _personalTitle = .init(personalTitle)
        self._birthDate = CalendarDateFormatted(rawValue: birthDate)
        self.firstName = firstName
        self.middleName = middleName
        self.lastName = lastName
        self.lastName2 = lastName2
        self.pseudo = pseudo
        self.birthPlace = birthPlace
        self.nationality = nationality
        self.creationDatetime = creationDatetime
        self.userModificationDatetime = userModificationDatetime
        self.spaceId = spaceId
        _attachments = .init(nil)
    }
}

extension Identity {
    public func validate() throws {
        if firstName.isEmptyOrWhitespaces() && middleName.isEmptyOrWhitespaces() && lastName.isEmptyOrWhitespaces()  {
            throw ItemValidationError(invalidProperty: \Identity.firstName)
        }
    }
    
    public mutating func prepareForSaving() {
        if pseudo.isEmpty && !defaultLogin.isEmpty {
            pseudo = defaultLogin
        }
    }
}

extension Identity: Searchable {
    public var searchableKeyPaths: [KeyPath<Identity, String>] {
        return [
            \Identity.firstName,
            \Identity.middleName,
            \Identity.lastName,
            \Identity.displayName,
            \Identity.displayNameInverted,
            \Identity.displayNameWithoutMiddleName,
            \Identity.displayNameWithoutMiddleNameInverted,
            \Identity.pseudo
        ]
    }
}

public extension Identity {
    var displayName: String {
        return  [firstName, middleName, lastName].joinedName()
    }
 
    var displayNameInverted: String {
        return [lastName, middleName, firstName].joinedName()
    }
    
    var displayNameWithoutMiddleName: String {
        return [firstName, lastName].joinedName()
    }
    
    var displayNameWithoutMiddleNameInverted: String {
        return [lastName, firstName].joinedName()
    }
}

extension Identity: Displayable {
    public var displayTitle: String {
        return displayName
    }
    
    public var displaySubtitle: String? {
       return defaultLogin
    }

    public var defaultLogin: String {
        if !pseudo.isEmpty {
            return pseudo
        }
        return [firstName, lastName]
            .joinedName(separator: ".")
            .replacingOccurrences(of: " ", with: "")
            .lowercased()
    }
   
    public var gender: Gender? {
        switch personalTitle {
        case .mr:
            return .male
        case .miss, .mrs, .ms:
            return .female
        case .mx, .noneOfThese:
            return nil
       
        }
    }
}

extension Array where Element == String {
    func joinedName(separator: String = " ") -> String {
        self
            .map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: separator)
    }
}

extension CountryCodeNamePair {
    var identityMode: Identity.Mode {
        if ["BE", "CH", "DE", "IT", "NL", "NO", "SE", "AT", "DK", "FR", "LU", "GB", "IE", "BR"].contains(code) {
            return .european
        }  else if ["MX", "CL", "CO", "ES", "PE", "PT", "AR"].contains(code) {
            return .spanish
        } else if ["JP"].contains(code) {
            return .japanese
        } else {
            return .northAmerican
        }
    }
}




public protocol IdentityLinked {
    var linkedIdentity: Identity? { get }
}

extension IdentityLinked {
    public var linkedIdentityFullName: String? {
        return  linkedIdentity?.displayName
    }
    
    var linkedIdentitySearchValue: String {
        guard let identity = self.linkedIdentity else {
            return ""
        }
        return
            [identity.displayName,
             identity.displayNameInverted,
             identity.displayNameWithoutMiddleName,
             identity.displayNameWithoutMiddleNameInverted].joined(separator: " ")
    }
}
