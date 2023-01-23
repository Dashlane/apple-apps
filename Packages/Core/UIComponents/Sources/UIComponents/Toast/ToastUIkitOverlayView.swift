#if canImport(UIKit)

import Foundation
import UIKit
import SwiftUI
import UIDelight
import SwiftTreats

struct ToastUIKitOverlay: View {
    @State
    var currentContent: ToastContent?

    @State
    var leading: CGFloat = 0

    var body: some View {
            ToastOverlay(currentContent: $currentContent)
                .onAppear {
                    ToastActionKey.defaultValue = ToastAction { view in
                        updateToastPosition()

                        currentContent = ToastContent(view: view)
                    }
                }
                .onDisappear {
                    ToastActionKey.defaultValue = ToastAction { _ in  }
                }
                .padding(.leading, leading)
    }

                                func updateToastPosition() {
        guard Device.isIpadOrMac else {
            return
        }

        if let rootViewController = UIApplication.shared.keyUIWindow?.rootViewController as? UISplitViewController,
           !rootViewController.isCollapsed {
            withAnimation(nil) {
                leading = rootViewController.primaryColumnWidth
            }
        } else {
            withAnimation(nil) {
                leading = 0
            }
        }
    }
}

public extension UIViewController {
        func turnOnToaster() {
        let controller = UIHostingController(rootView: ToastUIKitOverlay())

        addChild(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.backgroundColor = nil
        controller.view.isUserInteractionEnabled = false
        controller.view.isOpaque = false

        view.addSubview(controller.view)

        NSLayoutConstraint.activate([

            controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:0),
            controller.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            controller.view.heightAnchor.constraint(equalToConstant: 90),

            controller.view.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor, constant: 0)
        ])

        controller.didMove(toParent: controller)
    }
}

struct UIViewController_Previews: PreviewProvider {
    static let viewController: UIViewController = {
        let viewController = UIViewController()
        viewController.view = UIView()
        let hosting = UIHostingController(rootView:  List { ToastModifier_Previews.ContentView() } )
        hosting.view.backgroundColor = .red
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(hosting.view)
        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 0),
            hosting.view.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant:0),
            hosting.view.topAnchor.constraint(equalTo: viewController.view.topAnchor, constant: 0),
            hosting.view.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor, constant: 0)
        ])

        viewController.turnOnToaster()
        return viewController
    }()

    static var previews: some View {
        EmbeddedViewController(viewController)
    }
}

#endif
