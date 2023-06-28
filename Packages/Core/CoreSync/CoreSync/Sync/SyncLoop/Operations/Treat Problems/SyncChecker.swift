import Foundation
import DashTypes

public enum SyncSolution {
    case uploadTransaction(itemIdentifier: Identifier)
    case downloadTransaction(itemIdentifier: Identifier)
}

enum SyncProblem: Equatable, Hashable {
                case objectMissingRemotely(itemIdentifier: Identifier)
    case localObjectMoreRecent(itemIdentifier: Identifier)
                case objectMissingLocally(itemIdentifier: Identifier)
    case remoteObjectMoreRecent(itemIdentifier: Identifier)
}

final class SyncChecker {

                                func problems(remoteTransactions: Set<TimestampIdPair>,
                  localTransactions: Set<TimestampIdPair>,
                  existingProblems: Set<SyncProblem>) -> Set<SyncProblem> {
                let pertinentRemoteTransactions = remoteTransactions.subtracting(localTransactions)

                let pertinentLocalTransactions = localTransactions.subtracting(remoteTransactions
        )
        let remoteSet = Set(pertinentRemoteTransactions.map { $0.id })
        let localSet = Set(pertinentLocalTransactions.map { $0.id })
        let recentFilter: (TimestampIdPair) -> (TimestampIdPair) -> Bool = { item1 in
            return { item2 in
                item2.id == item1.id &&
                item2.timestamp < item1.timestamp
            }
        }
        let recentLocally = pertinentLocalTransactions.filter { remoteTransactions.first(where: recentFilter($0)) != nil }
            .map { SyncProblem.localObjectMoreRecent(itemIdentifier: $0.id) }
        let recentRemotely = pertinentRemoteTransactions.filter { localTransactions.first(where: recentFilter($0)) != nil }
            .map { SyncProblem.remoteObjectMoreRecent(itemIdentifier: $0.id) }
        let remoteOnly = remoteSet.subtracting(localSet)
            .map(SyncProblem.objectMissingLocally)
        let localOnly = localSet.subtracting(remoteSet)
            .map(SyncProblem.objectMissingRemotely)
        let problems = remoteOnly + localOnly + recentLocally + recentRemotely
        let filteredProblems = Set(problems).subtracting(existingProblems)
        return filteredProblems
    }
}

extension SyncSolution {

    init(_ problem: SyncProblem) {
        switch problem {
        case .localObjectMoreRecent(let itemIdentifier):
            self = .uploadTransaction(itemIdentifier: itemIdentifier)
        case .objectMissingRemotely(let itemIdentifier):
            self = .uploadTransaction(itemIdentifier: itemIdentifier)
        case .objectMissingLocally(let itemIdentifier):
            self = .downloadTransaction(itemIdentifier: itemIdentifier)
        case .remoteObjectMoreRecent(let itemIdentifier):
            self = .downloadTransaction(itemIdentifier: itemIdentifier)
        }
    }

    public var isUpload: Bool {
        switch self {
            case .uploadTransaction:
                return true
            case .downloadTransaction:
                return false
        }
    }

    public var isDownload: Bool {
        switch self {
            case .uploadTransaction:
                return false
            case .downloadTransaction:
                return true
        }
    }

    var identifier: Identifier {
        switch self {
        case .downloadTransaction(let id):
            return id
        case .uploadTransaction(let id):
            return id
        }
    }

}
