import Combine
import SwiftUI

@MainActor @Observable class ScreenLockAnimationOrchestrator {
  enum Animation {
    case unlock
    case lock
  }

  struct AnimationConfiguration {
    let lockPlaceholder: Image
    let contentPlaceholder: Image
    let animation: Animation
    fileprivate let completion: () -> Void
  }

  @ObservationIgnored
  weak var lockWindow: UIWindow?
  let mainWindow: UIWindow

  private(set) var currentAnimation: AnimationConfiguration?

  init(lockWindow: UIWindow, mainWindow: UIWindow) {
    self.lockWindow = lockWindow
    self.mainWindow = mainWindow
  }

  func completed() {
    if currentAnimation?.animation == .lock {
      currentAnimation = nil
    }

    currentAnimation?.completion()
  }

  func perform(_ animation: Animation, completion: @escaping () -> Void) {
    guard let lockWindow = lockWindow else {
      return
    }

    let lockPlaceholder = Image(uiImage: lockWindow.imageFromLayer())
    let contentPlaceholder = Image(uiImage: mainWindow.snapshotImage())

    currentAnimation = AnimationConfiguration(
      lockPlaceholder: lockPlaceholder,
      contentPlaceholder: contentPlaceholder,
      animation: animation,
      completion: completion)
  }
}
