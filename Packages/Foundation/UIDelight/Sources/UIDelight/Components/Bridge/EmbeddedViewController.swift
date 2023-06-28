#if canImport(UIKit)

import SwiftUI

public struct EmbeddedViewController: UIViewControllerRepresentable {
    private let viewControllerFactory: () -> UIViewController
    public init(_ viewControllerFactory: @escaping () -> UIViewController) {
        self.viewControllerFactory = viewControllerFactory
    }

    public init(_ viewControllerFactory: @autoclosure @escaping () -> UIViewController) {
        self.viewControllerFactory = viewControllerFactory
    }

    public func makeUIViewController(context: Context) -> UIViewController {
        viewControllerFactory()
    }

    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {

    }
}

#endif
