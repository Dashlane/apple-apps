import Combine
import Foundation

final class SQLiteInterProcessCommunicator: NSObject {
  enum Action: String, CaseIterable {
    case databaseUpdated
  }

  private static let notificationName = "com.dashlane.InterProcessCommunicator"
  private static func makeNotificationName(identifier: SQLiteClientIdentifier, action: Action)
    -> CFString
  {
    [notificationName, identifier.rawValue, action.rawValue].joined(separator: ".") as CFString
  }

  private static let receivedActions = PassthroughSubject<Action, Never>()

  var receivedActions: PassthroughSubject<Action, Never> {
    return Self.receivedActions
  }

  private let center = CFNotificationCenterGetDarwinNotifyCenter()
  private let identifier: SQLiteClientIdentifier

  init(identifier: SQLiteClientIdentifier) {
    self.identifier = identifier
    super.init()
    start()
  }

  deinit {
    stop()
  }

  private func start() {
    for action in Action.allCases {
      CFNotificationCenterAddObserver(
        center, Unmanaged.passRetained(self).toOpaque(),
        { (_, _, name, _, _) in
          guard let name = name?.rawValue,
            let actionString = (name as String).components(separatedBy: ".").last,
            let action = Action(rawValue: actionString)
          else {
            return
          }

          SQLiteInterProcessCommunicator.receivedActions.send(action)

        }, Self.makeNotificationName(identifier: identifier, action: action), nil,
        .deliverImmediately)
    }
  }

  private func stop() {
    CFNotificationCenterRemoveEveryObserver(center, Unmanaged.passRetained(self).toOpaque())
  }

  func post(_ action: Action) {
    for identifier in SQLiteClientIdentifier.allCases where identifier != self.identifier {
      let notification = Self.makeNotificationName(identifier: identifier, action: action)
      CFNotificationCenterPostNotification(
        CFNotificationCenterGetDarwinNotifyCenter(), CFNotificationName(rawValue: notification),
        nil, nil, true)
    }
  }
}
