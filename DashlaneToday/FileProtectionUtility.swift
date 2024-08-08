import Foundation
import UIKit

public final class FileProtectionUtility: NSObject {

  public static var isProtectedDataAvailable: (() -> Bool)!

  @objc public static let shared = FileProtectionUtility()

  public var lockState = LockState(initialState: .protectedDataAvailable)

  public struct LockState {
    public var state: State

    public enum State {
      case lockNotification, unlockNotification, protectedDataUnavailable, protectedDataAvailable
    }

    init(initialState: State) {
      self.state = initialState
    }

    mutating func transition(toState: State) {
      switch (state, toState) {
      case (.lockNotification, .protectedDataAvailable):
        return
      default:
        state = toState
        return
      }
    }

    nonmutating public func isLocked() -> Bool {
      switch self.state {
      case .lockNotification, .protectedDataUnavailable:
        return true
      default:
        return false
      }
    }
  }

  override init() {
    super.init()
    refreshProtectedDataAvailability()
    NotificationCenter.default.addObserver(
      forName: UIApplication.protectedDataDidBecomeAvailableNotification, object: nil,
      queue: OperationQueue.main,
      using: { (notification) in
        print("data did become available")
        self.lockState.transition(toState: .unlockNotification)
      })
    NotificationCenter.default.addObserver(
      forName: UIApplication.protectedDataWillBecomeUnavailableNotification, object: nil,
      queue: OperationQueue.main,
      using: { (notification) in
        print("data will become unavailable")
        self.lockState.transition(toState: .lockNotification)
      })
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  public func refreshProtectedDataAvailability() {
    if FileProtectionUtility.isProtectedDataAvailable() {
      lockState.transition(toState: .protectedDataAvailable)
    } else {
      lockState.transition(toState: .protectedDataUnavailable)
    }
  }

  public static func checkIfProtectedDataIsAvailable(at url: URL) throws -> Bool {
    let testData = "test".data(using: .utf8)!
    if !FileManager.default.fileExists(atPath: url.absoluteString) {
      try testData.write(to: url, options: [.completeFileProtection])
    }

    let data = try Data(contentsOf: url)
    return data == testData
  }
}
