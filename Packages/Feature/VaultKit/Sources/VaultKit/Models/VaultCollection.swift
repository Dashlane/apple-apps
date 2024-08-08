import Combine
import CorePersonalData
import CorePremium
import CoreSharing
import DashTypes

public struct VaultCollection: Equatable, Identifiable, Sendable {

  static let maxNameLength: Int = 100

  enum `Type`: Equatable {
    case `private`(PrivateCollection)

    case shared(SharedCollectionItems, spaceId: String?)
  }

  public var id: Identifier {
    switch type {
    case .private(let collection):
      return collection.id
    case .shared(let collection, _):
      return collection.id
    }
  }

  public var isShared: Bool {
    switch type {
    case .private:
      return false
    case .shared:
      return true
    }
  }

  public var name: String {
    switch type {
    case .private(let collection):
      return collection.name
    case .shared(let collectionItems, _):
      return collectionItems.collection.name
    }
  }

  public var privateCollection: PrivateCollection? {
    switch type {
    case .private(let collection):
      return collection
    default:
      return nil
    }
  }

  public var sharingPermission: SharingPermission? {
    switch type {
    case .shared(let collection, _):
      return collection.permission
    default:
      return nil
    }
  }

  public var spaceId: String? {
    switch type {
    case .private(let collection):
      return collection.spaceId
    case .shared(_, let spaceId):
      return spaceId
    }
  }

  public private(set) var itemIds: Set<Identifier>

  private(set) var type: `Type`

  public init(collection: PrivateCollection) {
    self.type = .private(collection)
    self.itemIds = Set(collection.items.map(\.id))
  }

  public init(
    collectionItems: SharedCollectionItems,
    spaceId: String?
  ) {
    self.type = .shared(collectionItems, spaceId: spaceId)
    self.itemIds = Set(collectionItems.itemIds)
  }

  public func contains<T: PersonalDataCodable>(_ element: T) -> Bool {
    return itemIds.contains(element.id)
  }
}

extension VaultCollection: Displayable {
  public var displayTitle: String {
    return name
  }

  public var displaySubtitle: String? {
    return nil
  }
}

extension VaultCollection: Searchable {
  public static var searchCategory: SearchCategory {
    return .collection
  }

  public var searchValues: [SearchValueConvertible] {
    return [name]
  }
}

extension VaultCollection {
  public func belongsToSpace(id: String?) -> Bool {
    return (spaceId ?? "") == (id ?? "")
  }

  public mutating func moveToSpace(withId spaceId: String?) {
    switch type {
    case .private(var collection):
      collection.spaceId = spaceId
      type = .private(collection)
    case .shared(let collection, _):
      type = .shared(collection, spaceId: spaceId)
    }
  }

  @discardableResult
  public mutating func remove<T: PersonalDataCodable>(_ element: T) -> Identifier? {
    switch type {
    case .private(var collection):
      collection.remove(element)
      type = .private(collection)
    case .shared(var collectionItems, let spaceId):
      collectionItems.itemIds.removeAll(where: { element.id == $0 })
      type = .shared(collectionItems, spaceId: spaceId)
    }
    return itemIds.remove(element.id)
  }

  @discardableResult
  public mutating func insert<T: PersonalDataCodable>(_ element: T) -> (
    inserted: Bool, memberAfterInsert: Identifier
  ) {
    switch type {
    case .private(var collection):
      if collection.insert(element).inserted {
        self.type = .private(collection)
      }
    case .shared(var collectionItems, let spaceId):
      collectionItems.itemIds.append(element.id)
      self.type = .shared(collectionItems, spaceId: spaceId)
    }
    return itemIds.insert(element.id)
  }
}
