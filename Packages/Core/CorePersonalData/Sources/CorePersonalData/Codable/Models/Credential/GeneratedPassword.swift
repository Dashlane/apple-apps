import Foundation
import DashTypes

public struct GeneratedPassword: PersonalDataCodable, Equatable {
    public static let contentType: PersonalDataContentType = .generatedPassword

    enum CodingKeys: CodingKey {
        case id
        case metadata
        case creationDatetime
        case authId
        case generatedDate
        case password
        case platform
        case domain
    }
    
    public let id: Identifier
    public let metadata: RecordMetadata
    public var creationDatetime: Date?
    public var authId: Identifier?
    public var generatedDate: Date?
    public var password: String?
    public var domain: PersonalDataURL?
    public var platform: String

    public init() {
        id = Identifier()
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        generatedDate = nil
        password = nil
        platform = ""
        domain = nil
        creationDatetime = Date()
        authId = nil
    }
}

extension GeneratedPassword: Searchable {
    public static let searchCategory: SearchCategory = .credential
    
            private var searchableURL: String {
        return domain?.rawValue ?? ""
    }
    
    public var searchableKeyPaths: [KeyPath<GeneratedPassword, String>] {
        var keyPathsList: [KeyPath<GeneratedPassword, String>] = []

        if domain != nil {
            keyPathsList.append(\GeneratedPassword.searchableURL)
        }
        
        return keyPathsList
    }
    
    public var secondarySearchableKeyPaths: [KeyPath<GeneratedPassword, String>] {
        searchableKeyPaths
    }
}

