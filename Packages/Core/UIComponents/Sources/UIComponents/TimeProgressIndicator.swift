import DesignSystem
import SwiftUI

public struct TimeProgressIndicator: View {

  @Binding
  var progress: CGFloat

  public init(progress: Binding<CGFloat>) {
    self._progress = progress
  }

  public var body: some View {
    Circle()
      .trim(from: 0, to: 1 - progress)
      .stroke(Color.ds.text.brand.quiet, lineWidth: 2)
      .rotationEffect(.degrees(-90))
      .background(Circle().stroke(Color.ds.container.agnostic.neutral.standard, lineWidth: 2))
      .rotationEffect(.degrees(180), anchor: .center)
      .rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
      .animation(.linear(duration: 1), value: progress)
      .transition(.identity)
      .aspectRatio(contentMode: .fit)
  }
}
