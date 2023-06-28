import Foundation
import Contacts
import DashTypes
import SwiftTreats

public struct Address: PersonalDataCodable, Equatable, Identifiable, Hashable, DatedPersonalData {
    public static let contentType: PersonalDataContentType = .address
    public static let searchCategory: SearchCategory = .personalInfo

    public enum CodingKeys: String, CodingKey {
        case id
        case anonId
        case metadata
        case name = "addressName"
        case streetNumber
        case addressFull
        case streetName
        case zipCode
        case city
        case state
        case country
        case localeFormat
        case linkedPhone
        case receiver
        case building
        case stairs
        case floor
        case door
        case digitCode
        case spaceId
        case attachments
        case creationDatetime
        case userModificationDatetime
    }

    public enum Mode {
        case europe
        case europeWithState
        case japan
        case asia
        case unitedKingdom
        case northAmericaAndAustralasia
    }

    public var id: Identifier
    public var anonId: String
    public let metadata: RecordMetadata
    public var name: String
        public var addressFull: String
        public var streetNumber: String
        public var streetName: String
    public var zipCode: String
    public var city: String
    public var state: StateCodeNamePair?
    public var country: CountryCodeNamePair?
        public var localeFormat: CountryCodeNamePair?

    public var linkedPhone: Identifier?
    public var receiver: String
    public var building: String
    public var stairs: String
    public var floor: String
    public var door: String
    public var digitCode: String
    public var creationDatetime: Date?
    public var userModificationDatetime: Date?
    public var spaceId: String?
    @JSONEncoded
    public var attachments: Set<Attachment>?

    public var mode: Mode {
        guard let country = self.country ?? CountryCodeNamePair.systemCountryCode else {
            return .europe
        }
        return country.addressMode
    }

    public init() {
        id = Identifier()
        anonId = UUID().uuidString
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        name = ""
        streetNumber = ""
        addressFull = ""
        streetName = ""
        zipCode = ""
        city = ""
        state = nil
        linkedPhone = nil
        receiver = ""
        building = ""
        stairs = ""
        floor  = ""
        door  = ""
        digitCode  = ""
        country = CountryCodeNamePair.systemCountryCode
        creationDatetime = Date()
        _attachments = .init(nil)
    }

    init(
        id: Identifier,
        anonId: String,
        name: String,
        addressFull: String,
        streetNumber: String,
        streetName: String,
        zipCode: String,
        city: String,
        state: StateCodeNamePair? = nil,
        country: CountryCodeNamePair? = nil,
        localeFormat: CountryCodeNamePair? = nil,
        linkedPhone: Identifier? = nil,
        receiver: String,
        building: String,
        stairs: String,
        floor: String,
        door: String,
        digitCode: String,
        creationDatetime: Date? = nil,
        userModificationDatetime: Date? = nil,
        spaceId: String? = nil
    ) {
        self.id = id
        self.anonId = anonId
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        self.name = name
        self.addressFull = addressFull
        self.streetNumber = streetNumber
        self.streetName = streetName
        self.zipCode = zipCode
        self.city = city
        self.state = state
        self.country = country
        self.localeFormat = localeFormat
        self.linkedPhone = linkedPhone
        self.receiver = receiver
        self.building = building
        self.stairs = stairs
        self.floor = floor
        self.door = door
        self.digitCode = digitCode
        self.creationDatetime = creationDatetime
        self.userModificationDatetime = userModificationDatetime
        self.spaceId = spaceId
        _attachments = .init(nil)
    }

                mutating func link(with phone: Phone) {
        self.linkedPhone = phone.id
    }
}

extension Address {
    public func validate() throws {
        if city.isEmptyOrWhitespaces() {
            throw ItemValidationError(invalidProperty: \Address.city)
        }
    }
}

extension Address: Searchable {
    public var searchableKeyPaths: [KeyPath<Address, String>] {
        [
            \Address.name,
            \Address.addressFull,
            \Address.receiver,
            \Address.building,
            \Address.stairs,
            \Address.floor,
            \Address.door,
            \Address.digitCode,
            \Address.streetName,
            \Address.streetNumber,
            \Address.zipCode,
            \Address.city
        ]
    }
}

extension Address {
    public mutating func prepareForSaving() {
        switch mode {
        case .unitedKingdom:
            addressFull = [streetName, streetNumber].filter { !$0.isEmpty }.joined(separator: " ")
        default:
            streetName = ""
            streetNumber = ""
        }

        localeFormat = country
    }
}

extension CountryCodeNamePair {
    var addressMode: Address.Mode {
        if ["AT", "DK", "FR", "LU"].contains(code) {
            return .europe
        } else if ["AR", "BE", "CH", "CL", "CO", "DE", "ES", "IT", "NL", "NO", "PE", "PT", "SE", "MX"].contains(code) {
            return .europeWithState
        } else if ["JP"].contains(code) {
            return .japan
        } else if ["CN", "IN", "KR", "BR"].contains(code) {
            return .asia
        } else if ["GB", "IE"].contains(code) {
            return .unitedKingdom
        } else if ["AU", "CA", "US", "NZ"].contains(code) {
            return .northAmericaAndAustralasia
        }
        return .europe
    }
}

public extension Address {
    var displayAddress: String {
        let address = CNMutablePostalAddress(address: self)
        let formatter = CNPostalAddressFormatter()
        return formatter.string(from: address)
    }

    var hasStairs: Bool {
        guard let code = country?.code else { return false }
        return !["GB", "US"].contains(code)
    }
}

extension CNMutablePostalAddress {
    convenience init(address: Address) {
        self.init()

        if !address.zipCode.isEmpty {
            self.postalCode = address.zipCode
        }
        if let country = address.country {
            if !country.name.isEmpty {
               self.country = country.name
            }
            self.isoCountryCode = country.code
        }

        if let state = address.state?.name, !state.isEmpty {
            self.state = state
        }

        if address.mode == .unitedKingdom {
            let street = [address.streetNumber, address.streetName]
                .filter {!$0.isEmpty}.joined(separator: " ")
            if !street.isEmpty {
                self.street = street
            }
        } else if !address.addressFull.isEmpty {
            self.street = address.addressFull
        }

        if !address.city.isEmpty {
            self.city = address.city
        }
    }
}
