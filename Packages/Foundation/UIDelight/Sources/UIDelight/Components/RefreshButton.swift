import SwiftUI
import Combine

public struct RefreshButton: View {
    public let action: () -> Void

    @StateObject
    private var executor = ThrottledExecutor()
    @State
    private var animationAmount = 0.0

    private let impactGenerator = UserFeedbackGenerator.makeImpactGenerator()

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: {
            executor.perform(action: performAction)
        }, label: {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(Font.system(size: 20).weight(.medium))
        })
        .rotationEffect(.degrees(animationAmount))
        .animation(.interpolatingSpring(mass: 0.7, stiffness: 50, damping: 5, initialVelocity: 0), value: animationAmount)
    }

    private func performAction() {
        self.animationAmount += 360
        action()
        impactGenerator?.impactOccurred()
    }
}

private class ThrottledExecutor: ObservableObject {
    private let debouncePublisher = PassthroughSubject<() -> Void, Never>()
    private let subscription: AnyCancellable
    init() {
        subscription = debouncePublisher
            .throttle(for: .milliseconds(500), scheduler: RunLoop.main, latest: true).sink {
                $0()
            }
    }
    func perform(action: @escaping () -> Void) {
        debouncePublisher.send(action)
    }
}

struct RefreshButton_Previews: PreviewProvider {
    static var previews: some View {
        RefreshButton {

        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
