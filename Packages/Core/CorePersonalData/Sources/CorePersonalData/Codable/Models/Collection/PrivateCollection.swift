import CoreTypes
import Foundation
import LogFoundation
import SwiftTreats

@Loggable
@PersonalData("COLLECTION")
public struct PrivateCollection: Equatable, Identifiable {
  public static let searchCategory: SearchCategory = .collection

  public struct ItemLink: Codable, Hashable {
    public var id: Identifier
    @RawRepresented
    public var type: XMLDataType?

    public init(id: Identifier = Identifier(), type: XMLDataType) {
      self.id = id
      self._type = .init(type)
    }

    public init(id: Identifier = Identifier(), rawType: String) {
      self.id = id
      self._type = .init(rawValue: rawType)
    }
  }

  public var name: String
  public var creationDatetime: Date?
  public var spaceId: String?

  @CodingKey("vaultItems")
  public var items: Set<ItemLink>

  public init(
    id: Identifier = Identifier(),
    name: String = "",
    creationDatetime: Date? = .now,
    spaceId: String? = nil,
    items: Set<ItemLink> = []
  ) {
    self.id = id
    self.metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
    self.name = name
    self.creationDatetime = creationDatetime
    self.spaceId = spaceId
    self.items = items
  }

  public func validate() throws {
    if name.isEmptyOrWhitespaces() {
      throw ItemValidationError(invalidProperty: \PrivateCollection.name)
    }
  }
}

extension PrivateCollection {
  @discardableResult
  public mutating func insert<T: PersonalDataCodable>(_ element: T) -> (
    inserted: Bool, memberAfterInsert: ItemLink
  ) {
    return items.insert(.init(id: element.id, type: .init(T.contentType)))
  }

  @discardableResult
  public mutating func remove<T: PersonalDataCodable>(_ element: T) -> ItemLink? {
    return items.remove(.init(id: element.id, type: .init(T.contentType)))
  }

  public func contains<T: PersonalDataCodable>(_ element: T) -> Bool {
    return items.contains(.init(id: element.id, type: .init(T.contentType)))
  }
}

extension PrivateCollection {
  public func belongsToSpace(id: String?) -> Bool {
    return (spaceId ?? "") == (id ?? "")
  }
}
