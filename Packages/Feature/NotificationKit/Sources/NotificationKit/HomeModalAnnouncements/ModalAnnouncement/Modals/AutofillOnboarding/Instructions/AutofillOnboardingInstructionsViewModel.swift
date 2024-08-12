import AVKit
import Foundation

@MainActor
@available(
  iOS, introduced: 16, deprecated: 17.0,
  message: "This should be removed as we have the ASSettingsHelper function instead."
)
class AutofillOnboardingInstructionsViewModel {

  let action: @MainActor () -> Void
  let close: @MainActor () -> Void
  let videoPlayer: AVPlayer

  init(
    action: @MainActor @escaping () -> Void,
    close: @MainActor @escaping () -> Void
  ) {
    let resourceName =
      UITraitCollection.current.userInterfaceStyle == .dark
      ? "ios-autofill-animation-dark" : "ios-autofill-animation"
    let url = Bundle.module.url(forResource: resourceName, withExtension: "mp4")!
    self.action = action
    self.close = close
    self.videoPlayer = .init(url: url)
  }

  func didTapGoToSettings() {
    action()
  }
}
