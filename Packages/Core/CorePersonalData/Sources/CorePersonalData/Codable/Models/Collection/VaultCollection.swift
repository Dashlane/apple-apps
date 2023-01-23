import Foundation
import DashTypes

public struct VaultCollection: PersonalDataCodable, Equatable, Identifiable, PersonalDataCategory {

    public static let contentType: PersonalDataContentType = .collection

    public struct ItemLink: Codable, Hashable {
        public var id: Identifier
        public var type: XMLDataType
    }

    enum CodingKeys: String, CodingKey {
        case id
        case anonId
        case metadata
        case name
        case creationDatetime
        case spaceId
        case items = "vaultItems"
    }

    public let id: Identifier
    public var anonId: String
    public let metadata: RecordMetadata
    public var name: String
    public var creationDatetime: Date?
    public var spaceId: String?

    public var items: Set<ItemLink>

    public init(
        id: Identifier = Identifier(),
        anionId: String = UUID().uuidString,
        name: String = "",
        creationDatetime: Date? = .now,
        spaceId: String? = nil,
        items: Set<ItemLink> = []
    ) {
        self.id = id
        self.anonId = anionId
        self.metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        self.name = name
        self.creationDatetime = creationDatetime
        self.spaceId = spaceId
        self.items = items
    }

    public func validate() throws {
        if name.isEmptyOrWhitespaces() {
            throw ItemValidationError(invalidProperty: \CredentialCategory.name)
        }
    }
}

extension VaultCollection {
                        @discardableResult
    public mutating func insert<T: PersonalDataCodable>(_ element: T) -> (inserted: Bool, memberAfterInsert: ItemLink) {
        return items.insert(.init(id: element.id, type: .init(T.contentType)))
    }

                @discardableResult
    public mutating func remove<T: PersonalDataCodable>(_ element: T) -> ItemLink? {
        return items.remove(.init(id: element.id, type: .init(T.contentType)))
    }
}

extension VaultCollection {
                    public func contains<T: PersonalDataCodable>(_ element: T) -> Bool {
        return items.contains(.init(id: element.id, type: .init(T.contentType)))
    }
}
