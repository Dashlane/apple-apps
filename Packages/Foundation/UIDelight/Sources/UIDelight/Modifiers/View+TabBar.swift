#if !os(macOS)
import SwiftUI
import UIKit

extension View {
        public func hideTabBar() -> some View {
        self.background(TabBarHider())
    }

                public func resetTabBarItemTitle(_ title: String) -> some View {
        self.modifier(ResetTabBarItemModifier(title: title))
    }
}

private struct TabBarHider: UIViewControllerRepresentable {

    class ViewController: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
                guard let tabBarController = self?.tabBarController else { return }
                tabBarController.tabBar.alpha = 0
            },
            completion: { [weak self] _ in
                guard let self = self, let tabBarController = self.tabBarController else { return }
                tabBarController.tabBar.isHidden = true
                self.updateSafeArea(with: tabBarController)
            })
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            guard let tabBarController = tabBarController else { return }

                                                            if let navigationController = navigationController, navigationController.viewControllers.count > 1 {
                return
            }

                        guard let transitionCoordinator = transitionCoordinator else {
                tabBarController.tabBar.isHidden = false
                tabBarController.tabBar.alpha = 1
                return
            }

            transitionCoordinator.animate(alongsideTransition: { _ in
                self.tabBarController.map { tabBarController in
                    tabBarController.tabBar.isHidden = false
                    tabBarController.tabBar.alpha = 1
                }
            },
            completion: { [weak self] _ in
                self?.updateSafeArea(with: tabBarController)
            })
        }

        private func updateSafeArea(with tabBarController: UITabBarController) {
                        let currentFrame = tabBarController.view.frame
            tabBarController.view.frame = currentFrame.insetBy(dx: 0, dy: 1)
            tabBarController.view.frame = currentFrame
        }
    }

    func makeUIViewController(context: Context) -> UIViewController {
        return ViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

private struct ResetTabBarItemModifier: ViewModifier {
    let title: String

    init(title: String) {
        self.title = title
    }

    func body(content: Content) -> some View {
        content.background(ResetTabBarItemViewController(tabBarItemTitle: title))
    }
}

private struct ResetTabBarItemViewController: UIViewControllerRepresentable {

    let tabBarItemTitle: String

    func makeCoordinator() -> Coordinator {
        Coordinator(tabBarItemTitle: tabBarItemTitle)
    }

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<ResetTabBarItemViewController>
    ) -> UIViewController {
        context.coordinator
    }

    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: UIViewControllerRepresentableContext<ResetTabBarItemViewController>
    ) { }

    class Coordinator: UIViewController {
        let tabBarItemTitle: String
        var tabBarItemIndex: Int?

        init(tabBarItemTitle: String) {
            self.tabBarItemTitle = tabBarItemTitle
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            getTabBarItemIndex()
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            setTabBarItemTitle()
        }

        private func getTabBarItemIndex() {
            tabBarItemIndex = tabBarController?.tabBar.items?.firstIndex(where: { $0.title == tabBarItemTitle })
        }

        private func setTabBarItemTitle() {
            guard let tabBarItemIndex else { return }
            tabBarController?.tabBar.items?[tabBarItemIndex].title = tabBarItemTitle
        }
    }
}

#endif
