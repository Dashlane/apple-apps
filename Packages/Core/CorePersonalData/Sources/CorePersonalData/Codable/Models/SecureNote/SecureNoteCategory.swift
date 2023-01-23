import Foundation
import DashTypes

public struct SecureNoteCategory: PersonalDataCodable, Equatable, Identifiable, PersonalDataCategory {
    public static let contentType: PersonalDataContentType = .secureNoteCategory

    enum CodingKeys: String, CodingKey {
        case id
        case anonId
        case metadata
        case name = "categoryName"
    }
    
    public var id: Identifier
    public var anonId: String
    public let metadata: RecordMetadata
    public var name: String
    
    public init() {
        id = Identifier()
        anonId = UUID().uuidString
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        name = ""
    }
    
    public func validate() throws {
        if name.isEmptyOrWhitespaces() {
            throw ItemValidationError(invalidProperty: \SecureNoteCategory.name)
        }
    }
}
