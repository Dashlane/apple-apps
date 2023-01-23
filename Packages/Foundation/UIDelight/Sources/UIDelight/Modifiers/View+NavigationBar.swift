#if !os(macOS)
import SwiftUI
import UIKit

extension View {
                            public func hideNavigationBar() -> some View {
        self.background(NavigationBarHider())
    }
}

private struct NavigationBarHider: UIViewControllerRepresentable {
    final class ViewController: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }

    func makeUIViewController(context: Context) -> UIViewController {
        return ViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
#endif
