import SwiftUI

public extension View {
                        func shakeAnimation(forNumberOfAttempts attempts: Int,
                        shakesCountPerAttemp: Int = 4,
                        duration: Double = 0.4) -> some View {
        return self
            .modifier(Shake(animatableData: CGFloat(attempts), shakesCount: shakesCountPerAttemp))
            .animation(Animation
                .easeInOut(duration: duration), value: attempts)
    }
}

private struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var animatableData: CGFloat
    var shakesCount: Int

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesCount)),
            y: 0))
    }
}

private struct TestingView: View {
    @State
    var attempts: Int = 0

    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.pink)
                .frame(width: 200, height: 100)
                .shakeAnimation(forNumberOfAttempts: attempts)

            Button(action: {
                self.attempts += 1
            }, label: {
                Text("Shake Me!")
            })
        }
    }
}

struct Shake_Previews: PreviewProvider {

    static var previews: some View {
        TestingView()
    }
}
