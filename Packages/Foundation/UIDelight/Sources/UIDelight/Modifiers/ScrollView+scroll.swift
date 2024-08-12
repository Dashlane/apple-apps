#if canImport(UIKit)
  import SwiftUI
  import UIKit

  extension ScrollView {

    public func enableScroll(_ enableScroll: Bool) -> some View {
      self
        .background(EnableScrollView(isScrollEnabled: enableScroll))
    }
  }

  private struct EnableScrollView: UIViewControllerRepresentable {

    let isScrollEnabled: Bool

    func makeUIViewController(context: Context) -> EnableScrollViewController {
      EnableScrollViewController(isScrollEnabled: isScrollEnabled)
    }

    func updateUIViewController(_ uiViewController: EnableScrollViewController, context: Context) {

    }
  }

  private final class EnableScrollViewController: UIViewController {

    let isScrollEnabled: Bool

    init(isScrollEnabled: Bool) {
      self.isScrollEnabled = isScrollEnabled
      super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      guard let scrollView = parent?.view.subviews.compactMap({ $0 as? UIScrollView }).last else {
        return
      }
      scrollView.isScrollEnabled = isScrollEnabled
      scrollView.bounces = isScrollEnabled
    }
  }
#endif
