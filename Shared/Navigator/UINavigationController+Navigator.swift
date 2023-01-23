import Foundation
import SwiftUI
import UIKit
import CoreFeature
import DashlaneAppKit
import CoreUserTracking
import DashTypes

extension DashlaneNavigationController: Navigator {
    var canDismiss: Bool {
        return self.presentingViewController != nil
    }

    func dismiss(animated: Bool) {
        dismiss(animated: animated, completion: nil)
    }

    func pop(animated: Bool) {
        popViewController(animated: animated)
    }

    func push<Content>(_ view: Content, barStyle: NavigationBarStyle, animated: Bool) where Content: View {
        let controller = makeContentViewController(for: view.dashlaneDefaultStyle(), using: barStyle)
        pushViewController(controller, animated: animated)
    }

    func setRootNavigation<Content: View>(_ view: Content, barStyle: NavigationBarStyle, animated: Bool) {
        let controller = makeContentViewController(for: view.dashlaneDefaultStyle(), using: barStyle)
        setViewControllers([controller], animated: animated)
    }

    func showDetail<Content: View>(_ view: Content, barStyle: NavigationBarStyle, animated: Bool) {
        let controller = makeContentViewController(for: view.dashlaneDefaultStyle(), using: barStyle)
        controller.hidesBottomBarWhenPushed = true
        pushViewController(controller, animated: animated)
    }

    @discardableResult
    func present<Content: View>(_ view: Content, presentationStyle: UIModalPresentationStyle = .automatic, barStyle: NavigationBarStyle, animated: Bool) -> DashlaneNavigationController {
        let controller = makeContentViewController(for: view.dashlaneDefaultStyle(), using: barStyle)
        return presentAsModal(controller, style: presentationStyle, animated: animated)
    }

    func present<Content: View>(_ view: Content, presentationStyle: UIModalPresentationStyle = .automatic, animated: Bool) {
        let controller = makeContentViewController(for: view.dashlaneDefaultStyle(), using: .default())
        self.present(controller, animated: true, completion: {

        })
    }

    private func makeContentViewController<Content: View>(for view: Content, using barStyle: NavigationBarStyle) -> UIViewController {

        let injectedView = view
            .environment(\.navigator, { [weak self] in return self })

        return NavigationContentHostingController(rootView: injectedView, navigationBarStyle: barStyle)
    }

    @discardableResult
    func presentAsModal(_ viewController: UIViewController, style: UIModalPresentationStyle, barStyle: NavigationBarStyle = .default(), animated: Bool) -> DashlaneNavigationController {

        let navigationController = DashlaneNavigationController()
        navigationController.pushViewController(viewController, animated: animated)
        viewController.modalPresentationStyle = .overFullScreen
        navigationController.navigationBar.applyStyle(barStyle)
        navigationController.modalPresentationStyle = style
        self.present(navigationController, animated: true, completion: {

        })
        return navigationController
    }

    func showDetailViewController(_ controller: UIViewController, animated: Bool) {
        controller.hidesBottomBarWhenPushed = true
        pushViewController(controller, animated: animated)
    }
    
    func pushViewController(_ viewController: UIViewController, barStyle: NavigationBarStyle, animated: Bool) {
        navigationBar.applyStyle(barStyle)
        setNavigationBarHidden(false, animated: animated)
        self.pushViewController(viewController, animated: animated)
    }
}

class DashlaneNavigationController: UINavigationController {
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not created from storyboard")
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }

    override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
                if let styleProvider = topViewController as? NavigationBarStyleProvider {
            setNavigationBarHidden(using: styleProvider.navigationBarStyle, animated: animated)
        } else {
            super.setNavigationBarHidden(hidden, animated: animated)
        }
    }

    func setNavigationBarHidden(using style: NavigationBarStyle, animated: Bool) {
        super.setNavigationBarHidden(style.shouldHide, animated: animated)
    }

        override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        guard action == #selector(handleMenuBarShortcut(_:)) else { return false }
        return true
    }

    @objc
    func handleMenuBarShortcut(_ sender: AnyObject) {
        guard let command = sender as? UICommand else {
            return
        }

        MainMenuBarBridge.shared.handle(command: command)
    }
}

extension UIViewController {
    var dashlaneNavigationController: DashlaneNavigationController? {
        return navigationController as? DashlaneNavigationController
    }
}

final class NavigationContentHostingController<T: View>: UIHostingController<T>, NavigationBarStyleProvider {
    var navigationBarStyle: NavigationBarStyle = .default()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle(navigationBarStyle: navigationBarStyle)
    }

    convenience init(rootView: T, navigationBarStyle: NavigationBarStyle) {
        self.init(rootView: rootView)
        self.navigationBarStyle = navigationBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = navigationBarStyle.largeTitleDisplayMode
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dashlaneNavigationController?.navigationBar.applyStyle(navigationBarStyle)
        dashlaneNavigationController?.setNavigationBarHidden(using: navigationBarStyle, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dashlaneNavigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
}
