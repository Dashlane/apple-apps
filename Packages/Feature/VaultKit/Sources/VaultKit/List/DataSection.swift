import Combine
import CorePersonalData
import CoreTypes
import Foundation

public struct DataSection: Identifiable {
  public enum `Type` {
    case none
    case suggestedItems
    case collection(name: String, isShared: Bool)
  }

  public let id: String
  public let name: String
  public let listIndex: Character
  public let type: `Type`
  public let items: [VaultItem]

  public var collectionName: String? {
    guard case .collection(let name, _) = type else { return nil }
    return name
  }

  public var isSharedCollection: Bool {
    guard case .collection(_, let isShared) = type else { return false }
    return isShared
  }

  public var isSuggestedItems: Bool {
    guard case .suggestedItems = type else { return false }
    return true
  }

  public init(
    name: String,
    listIndex: Character? = nil,
    type: `Type` = .none,
    items: [VaultItem]
  ) {
    if case .collection(let collectionName, _) = type {
      self.id = name + collectionName + (items.first?.spaceId ?? "")
    } else {
      self.id = name
    }
    self.name = name
    self.type = type
    self.listIndex = listIndex ?? name.listIndex
    self.items = items
  }
}

extension String {
  fileprivate var listIndex: Character {
    guard let character = localizedUppercase.first, character.isAllowedForIndexation else {
      return "#"
    }
    return character
  }
}

extension DataSection {
  public init<Item: VaultItem>(items: [Item]) {
    self.init(name: Item.localizedName, items: items)
  }
}

extension Publisher where Output == [DataSection] {
  public func filterEmpty() -> AnyPublisher<[DataSection], Failure> {
    return self.map { sections in
      return sections.filter { !$0.items.isEmpty }
    }.eraseToAnyPublisher()
  }
}
