import AsyncAlgorithms
import Combine
import UIKit

class FiberUIApplication: UIApplication {

  static let touchEvents = AsyncChannel<Void>()

  override func sendEvent(_ event: UIEvent) {
    super.sendEvent(event)

    guard event.type == .touches else {
      return
    }

    Task.detached(priority: .background) {
      await Self.touchEvents.send(Void())
    }
  }
}
