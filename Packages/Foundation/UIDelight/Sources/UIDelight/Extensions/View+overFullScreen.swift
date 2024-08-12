#if canImport(UIKit)
  import SwiftUI
  import UIKit

  struct OverFullScreenPresenter<Item, Content: View>: UIViewControllerRepresentable {
    @Binding
    var item: Item?
    let content: (Item) -> Content

    @MainActor
    class PresentationControllerDelegate: NSObject, UIAdaptivePresentationControllerDelegate,
      UIViewControllerTransitioningDelegate
    {

      let parent: OverFullScreenPresenter<Item, Content>
      init(parent: OverFullScreenPresenter<Item, Content>) {
        self.parent = parent
        super.init()
      }

      func adaptivePresentationStyle(
        for controller: UIPresentationController, traitCollection: UITraitCollection
      ) -> UIModalPresentationStyle {
        return .none
      }

      func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        guard parent.item != nil else {
          return
        }
        parent.item = nil
      }

      func animationController(forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning?
      {
        parent.item = nil
        return FadeOutAnimator()
      }

      func animationController(
        forPresented presented: UIViewController, presenting: UIViewController,
        source: UIViewController
      ) -> UIViewControllerAnimatedTransitioning? {
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
      if let item = item {
        guard
          uiViewController.presentedViewController?.presentationController?.delegate
            !== context.coordinator
        else {
          return
        }

        let contentViewController = UIHostingController(rootView: content(item))
        contentViewController.modalPresentationStyle = .overFullScreen
        contentViewController.view.backgroundColor = .clear
        contentViewController.view.isOpaque = false
        contentViewController.popoverPresentationController?.sourceView = uiViewController.view
        let targetedSize =
          contentViewController.popoverPresentationController?.frameOfPresentedViewInContainerView
          .size ?? UIScreen.main.bounds.size
        contentViewController.preferredContentSize = contentViewController.sizeThatFits(
          in: targetedSize)
        contentViewController.transitioningDelegate = context.coordinator
        contentViewController.presentationController?.delegate = context.coordinator
        uiViewController.present(contentViewController, animated: true, completion: nil)

      } else if let presentedViewController = uiViewController.presentedViewController,
        presentedViewController.presentationController?.delegate === context.coordinator
      {
        presentedViewController.dismiss(animated: true, completion: nil)
      }
    }
  }

  extension View {
    public func overFullScreen<Content: View>(
      isPresented: Binding<Bool>,
      @ViewBuilder content: @escaping () -> Content
    ) -> some View {
      let item = Binding(
        get: { isPresented.wrappedValue ? isPresented.wrappedValue : nil },
        set: { isPresented.wrappedValue = $0 ?? false })

      return self.background(OverFullScreenPresenter(item: item, content: { _ in content() }))
    }

    public func overFullScreen<Item, Content: View>(
      item: Binding<Item?>,
      @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
      return self.background(OverFullScreenPresenter(item: item, content: content))
    }
  }

  struct OverFullScreenPresenter_Previews: PreviewProvider {
    static var previews: some View {
      Text("Hello, World!").overFullScreen(isPresented: .constant(true)) {
        Text("Hello")
      }
    }
  }
#endif
