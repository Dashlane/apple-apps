import SwiftUI
import UIKit

struct PopoverPresenter<Content: View>: UIViewControllerRepresentable {
    @Binding
    var isPresented: Bool
    let content: Content
    let shouldDisplayPopoverOnSmallDevice: Bool

    class PresentationControllerDelegate: NSObject, UIAdaptivePresentationControllerDelegate {
        let parent: PopoverPresenter<Content>
        init(parent: PopoverPresenter<Content>) {
            self.parent = parent
            super.init()
        }

        func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
            return parent.shouldDisplayPopoverOnSmallDevice ? .none : .automatic
        }

        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            guard parent.isPresented else {
                return
            }
            parent.isPresented = false
        }
    }

    func makeCoordinator() -> PresentationControllerDelegate {
        PresentationControllerDelegate(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
            guard uiViewController.presentedViewController?.presentationController?.delegate !== context.coordinator else {
                return
            }

            let contentViewController = UIHostingController(rootView: content)
            contentViewController.modalPresentationStyle = .popover
            contentViewController.view.backgroundColor = .clear
            contentViewController.view.isOpaque = false
            contentViewController.popoverPresentationController?.sourceView = uiViewController.view
            let targetedSize = contentViewController.popoverPresentationController?.frameOfPresentedViewInContainerView.size ?? UIScreen.main.bounds.size
            contentViewController.preferredContentSize = contentViewController.sizeThatFits(in: targetedSize)

            contentViewController.presentationController?.delegate = context.coordinator
            uiViewController.present(contentViewController, animated: true, completion: nil)

        } else if let presentedViewController = uiViewController.presentedViewController,
            presentedViewController.presentationController?.delegate === context.coordinator {
            presentedViewController.dismiss(animated: true, completion: nil)
        }
    }
}

extension View {
    func popover<Content: View>(isPresented: Binding<Bool>,
                                shouldDisplayPopoverOnSmallDevice: Bool,
                                @ViewBuilder content: () -> Content) -> some View {
        self.background(PopoverPresenter(isPresented: isPresented,
                                          content: content(),
                                          shouldDisplayPopoverOnSmallDevice: shouldDisplayPopoverOnSmallDevice))
    }
}

struct PopoverAttachment_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello, World!").popover(isPresented: .constant(true), shouldDisplayPopoverOnSmallDevice: true) {
            Text("Hello")
        }
    }
}
