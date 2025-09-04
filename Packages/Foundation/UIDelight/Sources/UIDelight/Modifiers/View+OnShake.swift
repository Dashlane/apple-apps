import SwiftUI
import UIKit

private struct ShakeDetector: UIViewControllerRepresentable {
  let onShake: () -> Void

  final class MotionDetectorViewController: UIViewController {
    let onShake: () -> Void

    init(onShake: @escaping () -> Void) {
      self.onShake = onShake
      super.init(nibName: nil, bundle: nil)
      self.view = UIView(frame: .zero)

    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
      if motion == .motionShake {
        onShake()
      }
    }
  }

  func makeUIViewController(context: Context) -> MotionDetectorViewController {
    MotionDetectorViewController(onShake: onShake)
  }

  func updateUIViewController(_ controller: MotionDetectorViewController, context: Context) {

  }
}

extension View {
  public func onShake(_ action: @escaping () -> Void) -> some View {
    self.background(ShakeDetector(onShake: action))
  }
}
