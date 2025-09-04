import SwiftUI
import UIKit

extension View {
  public func overFullScreen<Content: View>(
    isPresented: Binding<Bool>,
    mode: OverFullScreenMode = .currentContext,
    @ViewBuilder content: @escaping () -> Content
  ) -> some View {
    let item = Binding(
      get: { isPresented.wrappedValue ? isPresented.wrappedValue : nil },
      set: { isPresented.wrappedValue = $0 ?? false })

    return self.background(
      OverFullScreenPresenter(item: item, mode: mode, content: { _ in content() }))
  }

  public func overFullScreen<Item, Content: View>(
    item: Binding<Item?>,
    mode: OverFullScreenMode = .currentContext,
    @ViewBuilder content: @escaping (Item) -> Content
  ) -> some View {
    return self.background(OverFullScreenPresenter(item: item, mode: mode, content: content))
  }
}

public enum OverFullScreenMode {
  case currentContext
  case topMost
}

private struct OverFullScreenPresenter<Item, Content: View>: UIViewControllerRepresentable {
  @Binding
  var item: Item?
  let mode: OverFullScreenMode
  let content: (Item) -> Content

  @MainActor
  class PresentationControllerDelegate: NSObject, UIAdaptivePresentationControllerDelegate,
    UIViewControllerTransitioningDelegate
  {
    weak var presentingController: UIViewController?

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
      presentingController = nil
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
      guard context.coordinator.presentingController == nil else {
        return
      }

      let presentingController =
        if mode == .topMost, let topMost = UIApplication.shared.topViewController() {
          topMost
        } else {
          uiViewController
        }
      context.coordinator.presentingController = presentingController

      guard
        presentingController.presentedViewController?.presentationController?.delegate
          !== context.coordinator
      else {
        return
      }

      let contentViewController = UIHostingController(rootView: content(item))
      contentViewController.modalPresentationStyle = .overFullScreen
      contentViewController.modalTransitionStyle = .crossDissolve
      contentViewController.view.backgroundColor = .clear
      contentViewController.view.isOpaque = false
      contentViewController.popoverPresentationController?.sourceView = uiViewController.view
      #if os(visionOS)
        let targetedSize =
          contentViewController.popoverPresentationController?.frameOfPresentedViewInContainerView
          .size
          ?? .zero
      #else
        let targetedSize =
          contentViewController.popoverPresentationController?.frameOfPresentedViewInContainerView
          .size
          ?? UIScreen.main.bounds.size
      #endif
      contentViewController.preferredContentSize = contentViewController.sizeThatFits(
        in: targetedSize)
      contentViewController.transitioningDelegate = context.coordinator
      contentViewController.presentationController?.delegate = context.coordinator

      presentingController.present(contentViewController, animated: true, completion: nil)
    } else if let presentedViewController = context.coordinator.presentingController?
      .presentedViewController,
      presentedViewController.presentationController?.delegate === context.coordinator
    {
      presentedViewController.dismiss(animated: true) {
        context.coordinator.presentingController = nil
      }
    }
  }
}

extension UIApplication {
  func topViewController() -> UIViewController? {
    var topController: UIViewController? = UIApplication.shared.keyUIWindow?.rootViewController
    while topController?.presentedViewController != nil {
      topController = topController?.presentedViewController
    }
    return topController
  }
}

struct OverFullScreenPresenter_Previews: PreviewProvider {
  static var previews: some View {
    Text("Hello, World!").overFullScreen(isPresented: .constant(true)) {
      Text("Hello")
    }
  }
}
