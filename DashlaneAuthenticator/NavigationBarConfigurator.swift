import Foundation
import SwiftUI

struct NavigationBarConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationBarConfigurator>) -> UIViewController {
        UIViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationBarConfigurator>) {
        if let navigationController = uiViewController.navigationController {
            self.configure(navigationController)
        }
    }

}
