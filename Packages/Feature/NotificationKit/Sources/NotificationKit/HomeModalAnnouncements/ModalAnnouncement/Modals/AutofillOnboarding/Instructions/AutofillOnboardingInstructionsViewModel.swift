import Foundation
import AVKit

@MainActor
class AutofillOnboardingInstructionsViewModel {

    let action: @MainActor () -> Void
    let close: @MainActor () -> Void
    let videoPlayer: AVPlayer

    init(action: @MainActor @escaping () -> Void,
         close: @MainActor @escaping () -> Void) {
        let resourceName = UITraitCollection.current.userInterfaceStyle == .dark ? "ios-autofill-animation-dark" : "ios-autofill-animation"
        let url = Bundle.module.url(forResource: resourceName, withExtension: "mp4")!
        self.action = action
        self.close = close
        self.videoPlayer = .init(url: url)
    }

    func didTapGoToSettings() {
        action()
    }
}
