import SwiftUI
#if !os(macOS)
import UIKit

private struct LifyCycleHandler: UIViewControllerRepresentable {
    func makeCoordinator() -> LifyCycleHandler.Coordinator {
        Coordinator(onWillDisappear: onWillDisappear, onWillAppear: onWillAppear)
    }

    let onWillDisappear: () -> Void
    let onWillAppear: () -> Void

    func makeUIViewController(context: UIViewControllerRepresentableContext<LifyCycleHandler>) -> UIViewController {
        context.coordinator
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<LifyCycleHandler>) {
    }

    typealias UIViewControllerType = UIViewController

    class Coordinator: UIViewController {
        let onWillDisappear: () -> Void
        let onWillAppear: () -> Void

        init(onWillDisappear: @escaping () -> Void, onWillAppear: @escaping () -> Void) {
            self.onWillDisappear = onWillDisappear
            self.onWillAppear = onWillAppear
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            onWillDisappear()
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            onWillAppear()
        }
    }
}

private struct LifeCycleModifier: ViewModifier {
    let onWillAppear: () -> Void
    let onWillDisappear: () -> Void

    func body(content: Content) -> some View {
        content
            .background(LifyCycleHandler(onWillDisappear: onWillDisappear, onWillAppear: onWillAppear))
    }
}

extension View {
    public func lifeCycleEvent(onWillAppear: @escaping () -> Void = {},
                               onWillDisappear: @escaping () -> Void = {}) -> some View {
        self.modifier(LifeCycleModifier(onWillAppear: onWillAppear, onWillDisappear: onWillDisappear))
    }
}
#endif
