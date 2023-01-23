import Foundation
import Combine
import CorePersonalData
import DashlaneAppKit
import CoreSettings
import VaultKit

extension Publisher where Output: Collection, Output.Element: VaultItem & Categorisable, Failure == Never {
        func sort<SortingPublisher: Publisher>(using publisher: SortingPublisher) -> AnyPublisher<[DataSection], Never> where SortingPublisher.Failure == Failure, SortingPublisher.Output == VaultItemSorting {
        return self.combineLatest(publisher) { items, sorting -> [DataSection] in
            switch sorting {
                case .sortedByName:
                    return items.alphabeticallyGrouped()
                case .sortedByCategory:
                    return items.groupedByCategory()
            }
        }.eraseToAnyPublisher()
    }
}

private extension L10n.Localizable {
    static let noCategoryName = L10n.Localizable.kwNoCategory.uppercased()
}

private struct CategorySortingKey: Hashable {
    let name: String
    let index: Character?
}

extension Collection where Element: VaultItem & Categorisable {
        func groupedByCategory() -> [DataSection] {
        return Dictionary(grouping: self) { item in
            guard let categoryName = item.category?.name else {
                return L10n.Localizable.noCategoryName
            }
            return categoryName.uppercased()
        }.map {
            DataSection(name: $0.key,
                        listIndex: $0.key == L10n.Localizable.noCategoryName ? "•" : nil,
                        items: $0.value.alphabeticallySorted())
        }.sorted {
            if $0.name == L10n.Localizable.noCategoryName {
                return false
            } else if $1.name == L10n.Localizable.noCategoryName {
                return true
            } else {
                return $0.name < $1.name
            }
        }
    }
}
