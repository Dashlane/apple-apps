import Combine
import Foundation

class SQLiteDriverEventNotifier {
  let eventPublisher = PassthroughSubject<DatabaseEvent, Never>()
  private let internalEventPublisher = PassthroughSubject<DatabaseEvent, Never>()
  private let interProcessCommunicator: SQLiteInterProcessCommunicator
  var subscriptions = Set<AnyCancellable>()

  init(identifier: SQLiteClientIdentifier) {
    interProcessCommunicator = SQLiteInterProcessCommunicator(identifier: identifier)
    configureEvents()
  }

  private func configureEvents() {
    interProcessCommunicator.receivedActions
      .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main, options: nil)
      .filter {
        $0 == .databaseUpdated
      }.sink { [internalEventPublisher] _ in
        internalEventPublisher.send(.invalidation)
      }.store(in: &subscriptions)

    internalEventPublisher
      .collect(.byTime(DispatchQueue.global(qos: .background), .milliseconds(50)))
      .map { events -> DatabaseEvent in
        var aggregatedChanges: Set<DatabaseChange> = .init()
        for event in events {
          switch event {
          case .invalidation:
            return .invalidation
          case let .incrementalChanges(changes):
            aggregatedChanges.formUnion(changes)
          }
        }
        return .incrementalChanges(aggregatedChanges)
      }
      .sink { [eventPublisher] event in
        eventPublisher.send(event)
      }
      .store(in: &subscriptions)
  }

  func notify(_ event: DatabaseEvent) {
    internalEventPublisher.send(event)
    interProcessCommunicator.post(.databaseUpdated)
  }
}
