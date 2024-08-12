import Foundation
import WatchConnectivity

final class WatchAppConnectivity: NSObject, WCSessionDelegate {
  @Published var context: WatchApplicationContext?

  override init() {
    super.init()

    if WCSession.isSupported() {
      WCSession.default.delegate = self
      WCSession.default.activate()
    }
  }

  private func updateContext(from dictionary: [String: Any]) {
    guard let newContext = try? WatchApplicationContext.fromDict(dictionary) else { return }
    newContext.tokens.sort { $0.title < $1.title }

    if let data = try? JSONEncoder().encode(newContext) {
      try? data.write(to: URL.contextUrl(), options: .completeFileProtection)
    }

    DispatchQueue.main.async {
      self.context = newContext
    }
  }

  func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {
    self.updateContext(from: session.receivedApplicationContext)
  }

  func session(
    _ session: WCSession,
    didReceiveApplicationContext applicationContext: [String: Any]
  ) {
    self.updateContext(from: applicationContext)
  }
}
