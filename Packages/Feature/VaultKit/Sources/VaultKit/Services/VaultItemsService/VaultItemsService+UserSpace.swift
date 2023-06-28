import Combine
import CorePersonalData
import CorePremium
import Foundation

private extension Array where Element == VaultItem {
    func filter(by space: UserSpace) -> [VaultItem] {
        switch space {
        case .personal, .business:
            return self.filter { $0.spaceId == space.personalDataId }
        case .both:
            return self
        }
    }
}

private extension Array where Element == VaultCollection {
    func filter(by space: UserSpace) -> [VaultCollection] {
        switch space {
        case .personal, .business:
            return self.filter { $0.spaceId ?? "" == space.personalDataId }
        case .both:
            return self
        }
    }
}

extension Publisher where Output == [VaultItem], Failure == Never {
            public func filter<SpacePublisher: Publisher>(by space: SpacePublisher) -> AnyPublisher<[VaultItem], Failure> where SpacePublisher.Output == UserSpace, SpacePublisher.Failure == Failure {
        return self.combineLatest(space) { items, space in
            return items.filter(by: space)
        }.eraseToAnyPublisher()
    }
}

extension Publisher where Output == [VaultCollection], Failure == Never {
            public func filter<SpacePublisher: Publisher>(by space: SpacePublisher) -> AnyPublisher<[VaultCollection], Failure> where SpacePublisher.Output == UserSpace, SpacePublisher.Failure == Failure {
        return self.combineLatest(space) { collections, space in
            return collections.filter(by: space)
        }.eraseToAnyPublisher()
    }
}

extension Publisher where Output == [DataSection], Failure == Never {
            public func filter<SpacePublisher: Publisher>(by space: SpacePublisher) -> AnyPublisher<[DataSection], Failure> where SpacePublisher.Output == UserSpace, SpacePublisher.Failure == Failure {
        return self.combineLatest(space) { sections, space in
            return sections.map {
                DataSection(name: $0.name, listIndex: $0.listIndex, items: $0.items.filter(by: space))
            }
        }.eraseToAnyPublisher()
    }
}
