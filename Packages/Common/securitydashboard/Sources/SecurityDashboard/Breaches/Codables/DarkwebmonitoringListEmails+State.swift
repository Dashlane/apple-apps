import DashlaneAPI
import Foundation

public typealias DataLeakEmail = DarkwebmonitoringListEmails

extension DataLeakEmail {

  public enum State: String, Codable {
    case pending
    case active
    case disabled
  }

  public init(pendingEmail: String) {
    self.init(
      email: pendingEmail,
      state: State.pending.rawValue)
  }
}

extension DataLeakEmail: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(email)
    hasher.combine(state)
    hasher.combine(expiresIn)
  }
}

extension Collection where Element == DataLeakEmail {
  public func ordered() -> [DataLeakEmail] {
    return self.sorted(by: {

      guard let firstState = DataLeakEmail.State(rawValue: $0.state),
        let secondState = DataLeakEmail.State(rawValue: $1.state),
        firstState != secondState
      else {
        return $0.email < $1.email
      }
      return firstState.orderValue < secondState.orderValue
    })
  }
}

extension DataLeakEmail.State {
  fileprivate var orderValue: Int {
    switch self {
    case .pending: return 0
    case .active: return 1
    case .disabled: return 2
    }
  }
}
