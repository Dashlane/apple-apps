import Foundation
import SwiftUI
import UIDelight

enum Lock: Equatable {
        case privacyShutter
        case secure
}

struct GlobalFullScreenCoverLock<Content: View>: UIViewControllerRepresentable {

    @Binding
    var lock: Lock?
    
    let content: () -> Content

    struct ModalLockSession {
        let window: UIWindow
        let backgroundViewController: UIViewController
        let lockViewController: UIViewController
        let lock: Lock
    }

    class PresentationControllerDelegate: NSObject, UIAdaptivePresentationControllerDelegate, UIViewControllerTransitioningDelegate {

        let parent: GlobalFullScreenCoverLock<Content>
        var currentLockSession: ModalLockSession?

        init(parent: GlobalFullScreenCoverLock<Content>) {
            self.parent = parent
            super.init()
        }

        func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
            return .none
        }

        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            parent.lock = nil
        }

        func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            return LockAnimator(isOpening: true)
        }

         func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
           return FadeInAnimator()
         }
    }

    func makeCoordinator() -> PresentationControllerDelegate {
        PresentationControllerDelegate(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let lock = lock, let baseWindow = uiViewController.view.window {

            guard context.coordinator.currentLockSession == nil || context.coordinator.currentLockSession?.lock != lock else {
                return
            }
            let modalWindow = makeLockWindow(baseWindow: baseWindow)

            let backgroundViewController = UIViewController()
            backgroundViewController.view = context.coordinator.currentLockSession?.window == nil ? baseWindow.snapshotView(afterScreenUpdates: false) : context.coordinator.currentLockSession!.window.snapshotView(afterScreenUpdates: false)
            modalWindow.rootViewController = backgroundViewController

            let lockViewController = UIHostingController(rootView: content())
            lockViewController.transitioningDelegate = context.coordinator
            lockViewController.modalPresentationStyle = .fullScreen

            context.coordinator.currentLockSession = ModalLockSession(window: modalWindow,
                                                  backgroundViewController: backgroundViewController,
                                                                      lockViewController: lockViewController,
                                                                      lock: lock)

            modalWindow.makeKeyAndVisible()
            modalWindow.isHidden = false

            modalWindow.rootViewController?.present(lockViewController,
                                                    animated: true)

        } else {
            guard let modalSession = context.coordinator.currentLockSession,
            let baseWindow = uiViewController.view.window else {
                return
            }
            modalSession.backgroundViewController.view = baseWindow.snapshotView(afterScreenUpdates: false)
            modalSession.lockViewController.dismiss(animated: true) {
                modalSession.window.isHidden = true
                context.coordinator.currentLockSession = nil
            }
        }

    }

    private func makeLockWindow(baseWindow: UIWindow) -> UIWindow {
        let modalWindow: UIWindow
        if let scene = baseWindow.windowScene {
            modalWindow = UIWindow(windowScene: scene)
        } else {
            modalWindow = UIWindow(frame: UIScreen.main.bounds)
        }

        modalWindow.backgroundColor = .black
        modalWindow.windowLevel = .statusBar + 1

        return modalWindow
    }
}

extension View {
  
    func globalFullScreen<Content: View>(lock: Binding<Lock?>,
                                       @ViewBuilder content:  @escaping (Lock?) -> Content) -> some View {
        return self.background(GlobalFullScreenCoverLock(lock: lock,
                                                         content: { content(lock.wrappedValue) }))
    }
    
}

struct GlobalFullScreenCoverLock_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello, World!").globalFullScreen(lock: .constant(.privacyShutter)) { _ in
            Text("Hello")
        }
    }
}
