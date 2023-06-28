import Foundation
import DashTypes

public struct CredentialCategory: PersonalDataCodable, Equatable, Identifiable {
    public static let contentType: PersonalDataContentType = .credentialCategory

    enum CodingKeys: String, CodingKey {
        case id
        case anonId
        case metadata
        case name = "categoryName"
    }

    public let id: Identifier
    public var anonId: String
    public let metadata: RecordMetadata
    public var name: String

    public init(id: Identifier = Identifier(), name: String = "") {
        self.id = id
        anonId = UUID().uuidString
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        self.name = name
    }

    public func validate() throws {
        if name.isEmptyOrWhitespaces() {
            throw ItemValidationError(invalidProperty: \CredentialCategory.name)
        }
    }
}
