import Foundation
import Combine
import DashTypes

public struct DataSection: Identifiable {
    public enum `Type` {
        case none
        case suggestedItems
        case collection(name: String)
    }

    public let id: String
    public let name: String
        public let listIndex: Character
    public let type: `Type`
    public let items: [VaultItem]

    public var collectionName: String? {
        guard case .collection(let name) = type else { return nil }
        return name
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
        if case .collection(let collectionName) = type {
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

private extension String {
    var listIndex: Character {
        guard let character = localizedUppercase.first, character.isAllowedForIndexation else {
            return "#"
        }
        return character
    }
}

public extension DataSection {
    init<Item: VaultItem>(items: [Item]) {
        self.init(name: Item.localizedName, items: items)
    }
}

public extension Publisher where Output == [DataSection] {
    func filterEmpty() -> AnyPublisher<[DataSection], Failure> {
        return self.map { sections in
            return sections.filter { !$0.items.isEmpty }
        }.eraseToAnyPublisher()
    }
}
