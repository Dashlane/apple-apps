import Foundation
import Combine
import DashTypes

public struct DataSection {
    public let name: String
        public let listIndex: Character
    public let isSuggestedItems: Bool
    public let items: [VaultItem]

    public init(name: String,
                listIndex: Character? = nil,
                isSuggestedItems: Bool = false,
                items: [VaultItem]) {
        self.name = name
        self.isSuggestedItems = isSuggestedItems
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
