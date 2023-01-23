import Foundation
import Combine

public protocol BreachesStore {
        var lastRevisionForPublicBreaches: Int? { get set }

        var lastUpdateDateForDataLeakBreaches: TimeInterval? { get set }

        func breachesPublisher() -> AnyPublisher<Set<StoredBreach>, Never>

        func fetch() -> Set<StoredBreach>

        func create(_ breaches: Set<StoredBreach>)

        func update(_ breaches: Set<StoredBreach>)
}
