import DashTypes
import Foundation

enum SyncProblem: Equatable, Hashable {
  case objectMissingRemotely(itemIdentifier: Identifier)
  case localObjectMoreRecent(itemIdentifier: Identifier)
  case objectMissingLocally(itemIdentifier: Identifier)
  case remoteObjectMoreRecent(itemIdentifier: Identifier)
}

extension Set<SyncProblem> {
  init(
    remoteTransactionsSummary: Set<TimestampIdPair>, localTransactionsSummary: Set<TimestampIdPair>
  ) {
    let recentLocally = localTransactionsSummary.filterMoreRecent(
      against: remoteTransactionsSummary
    )
    .map { SyncProblem.localObjectMoreRecent(itemIdentifier: $0.id) }
    let recentRemotely = remoteTransactionsSummary.filterMoreRecent(
      against: localTransactionsSummary
    )
    .map { SyncProblem.remoteObjectMoreRecent(itemIdentifier: $0.id) }

    let remoteSet = Set<Identifier>(remoteTransactionsSummary.map(\.id))
    let localSet = Set<Identifier>(localTransactionsSummary.map(\.id))
    let remoteOnly = remoteSet.subtracting(localSet).map(SyncProblem.objectMissingLocally)
    let localOnly = localSet.subtracting(remoteSet).map(SyncProblem.objectMissingRemotely)
    self = Set(remoteOnly + localOnly + recentLocally + recentRemotely)
  }
}

extension Set<TimestampIdPair> {
  func filterMoreRecent(against transactions: Set<TimestampIdPair>) -> some Collection<
    TimestampIdPair
  > {
    filter { item1 in
      transactions.contains { item2 in
        item2.id == item1.id && item2.timestamp < item1.timestamp
      }
    }
  }
}
