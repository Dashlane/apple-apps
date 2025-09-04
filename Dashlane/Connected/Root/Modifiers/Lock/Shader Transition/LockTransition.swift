import SwiftTreats
import SwiftUI

extension AnyTransition {
  static func precompileUnlockTransition() {
    Task {
      if #available(iOS 18.0, *) {
        let shader = ShaderLibrary.makeUnlock(size: .zero, displacement: 0, progress: 0)
        try await shader.compile(as: .layerEffect)
      }
    }
  }
  public static let unlock: AnyTransition = .modifier(
    active: UnlockTransitionModifier(progress: 1), identity: UnlockTransitionModifier(progress: 0))
}

private struct UnlockTransitionModifier: ViewModifier, Animatable {
  var progress: Float

  var animatableData: Float {
    get { progress }
    set { progress = newValue }
  }

  func body(content: Content) -> some View {
    content
      .visualEffect { visualEffet, proxy in
        let shader = ShaderLibrary.makeUnlock(
          size: proxy.size, displacement: 0.25, progress: progress)
        return visualEffet.layerEffect(shader, maxSampleOffset: .zero, isEnabled: progress > 0)
      }
  }
}

extension ShaderLibrary {
  static func makeUnlock(size: CGSize, displacement: Float, progress: Float) -> Shader {
    ShaderLibrary.unlock(
      .float2(size.width, size.height),
      .float(Device.is(.mac, .pad) ? 0.15 : 0.25),
      .float(progress)
    )
  }
}
