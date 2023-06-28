import SwiftUI
import DesignSystem

public struct TimeProgressIndicator: View {

    let progress: CGFloat
    let code: String

    public init(progress: CGFloat, code: String) {
        self.progress = progress
        self.code = code
    }

    public var body: some View {
        Circle()
            .trim(from: 0, to: 1 - progress)
            .stroke(Color.ds.text.brand.quiet, lineWidth: 2)
            .rotationEffect(.degrees(-90))
            .background(Circle().stroke(Color.ds.container.agnostic.neutral.standard, lineWidth: 2))
            .rotationEffect(.degrees(180), anchor: .center)
            .rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
            .frame(width: 20, height: 20)
            .animation(.linear(duration: 1), value: progress)
            .transition(.identity)
            .id(code)
    }
}
