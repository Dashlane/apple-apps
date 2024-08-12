import Foundation
import SwiftUI

#if targetEnvironment(macCatalyst)
  extension View {
    func transparentSidebar() -> some View {
      self.background(SplitViewHack())
    }
  }

  private struct SplitViewHack: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> HackSplitViewController {
      HackSplitViewController()
    }

    func updateUIViewController(_ uiViewController: HackSplitViewController, context: Context) {

    }
  }

  private final class HackSplitViewController: UIViewController {
    init() {
      super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      parent?.view.backgroundColor = .clear
    }
  }
#endif
