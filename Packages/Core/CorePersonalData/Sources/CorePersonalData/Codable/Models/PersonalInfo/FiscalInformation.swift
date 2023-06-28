import Foundation
import DashTypes
import SwiftTreats

public struct FiscalInformation: PersonalDataCodable, Equatable, Identifiable, DatedPersonalData {
    public static let contentType: PersonalDataContentType = .taxNumber
    public static let searchCategory: SearchCategory = .personalInfo

    enum CodingKeys: String, CodingKey {
        case id
        case anonId
        case metadata
        case fiscalNumber
        case teledeclarationNumber = "teledeclarantNumber"
        case creationDatetime
        case userModificationDatetime
        case country = "localeFormat"
        case spaceId
        case attachments
    }

    public let id: Identifier
    public var anonId: String
    public let metadata: RecordMetadata
    public var fiscalNumber: String
    public var teledeclarationNumber: String
    public var creationDatetime: Date?
    public var userModificationDatetime: Date?
    public var country: CountryCodeNamePair?
    public var spaceId: String?
    @JSONEncoded
    public var attachments: Set<Attachment>?

    public enum Mode {
        case franceAndBelgium
        case other
    }

    public var mode: Mode {
        guard let country = self.country ?? CountryCodeNamePair.systemCountryCode else {
            return .other
        }
        return country.fiscalMode
    }

    public init() {
        id = Identifier()
        anonId = UUID().uuidString
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        fiscalNumber = ""
        teledeclarationNumber = ""
        creationDatetime = Date()
        country = CountryCodeNamePair.systemCountryCode
        _attachments = .init(nil)
    }

    init(id: Identifier, anonId: String, fiscalNumber: String, teledeclarationNumber: String, creationDatetime: Date? = nil, userModificationDatetime: Date? = nil, country: CountryCodeNamePair? = nil, spaceId: String? = nil) {
        self.id = id
        self.anonId = anonId
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        self.fiscalNumber = fiscalNumber
        self.teledeclarationNumber = teledeclarationNumber
        self.creationDatetime = creationDatetime
        self.userModificationDatetime = userModificationDatetime
        self.country = country
        self.spaceId = spaceId
        _attachments = .init(nil)
    }

}

extension FiscalInformation {
    public func validate() throws {
        if fiscalNumber.isEmptyOrWhitespaces() {
            throw ItemValidationError(invalidProperty: \FiscalInformation.fiscalNumber)
        }
    }
}

extension FiscalInformation: Searchable {
    public var searchableKeyPaths: [KeyPath<FiscalInformation, String>] {
        return [
            \FiscalInformation.fiscalNumber,
            \FiscalInformation.teledeclarationNumber
        ]
    }
}

extension CountryCodeNamePair {
    var fiscalMode: FiscalInformation.Mode {
        if ["FR", "BE"].contains(code) {
            return .franceAndBelgium
        }
        return .other
    }
}
