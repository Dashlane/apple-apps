import SwiftUI
import Combine
#if !os(macOS)

public struct KeyboardSpacer: View {
        @State
    private var keyboardHeight: CGFloat = 0

    @State
    private var bottomOffset: CGFloat = 0

    private var spacerHeight: CGFloat {
        max(self.keyboardHeight - self.bottomOffset, 0)
    }

    private let anim = Animation.interpolatingSpring(mass: 3, stiffness: 1000, damping: 500, initialVelocity: 1)

    private let showPublisher = NotificationCenter.Publisher.init(
        center: .default,
        name: UIResponder.keyboardWillShowNotification
    ).map { (notification) -> CGFloat in
        guard let rect = notification.userInfo?[ UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return 0 }
        return rect.height
    }

    private let hidePublisher = NotificationCenter.Publisher.init(
        center: .default,
        name: UIResponder.keyboardWillHideNotification
    ).map { _ -> CGFloat in 0 }

    private let keyboardAppearancePublisher: AnyPublisher<CGFloat, Never>

    public init() {
        self.keyboardAppearancePublisher = self.showPublisher.merge(with: self.hidePublisher).receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    public var body: some View {
        Spacer()
            .frame(height: self.spacerHeight)
            .onReceive(self.keyboardAppearancePublisher) { (height) in
                withAnimation(self.anim) {
                    self.keyboardHeight = height
                }
            }
            .background(safeAreaInsetsGetter).onPreferenceChange(SafeAreaPreferenceKey.self) { safeArea in
                self.bottomOffset = safeArea.bottom
            }
    }

        private var safeAreaInsetsGetter: some View {
        GeometryReader { proxy in
            Rectangle().foregroundColor(.clear).preference(key: SafeAreaPreferenceKey.self, value: proxy.safeAreaInsets)
        }
    }
}

private struct SafeAreaPreferenceKey: PreferenceKey {
    static var defaultValue = EdgeInsets()

    static func reduce(value: inout EdgeInsets, nextValue: () -> EdgeInsets) {
        value = nextValue()
    }
}

#endif
