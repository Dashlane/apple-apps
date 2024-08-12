#if canImport(UIKit)
  import Foundation
  import SwiftUI
  import SafariServices
  import UIKit

  public struct InApplicationSafariView: UIViewControllerRepresentable {

    let url: URL

    public init(url: URL) {
      self.url = url
    }

    public func makeUIViewController(
      context: UIViewControllerRepresentableContext<InApplicationSafariView>
    ) -> SFSafariViewController {
      let controller = SFSafariViewController(url: url)
      controller.preferredBarTintColor = .systemBackground
      controller.preferredControlTintColor = UIColor(Color.accentColor)
      return controller

    }

    public func updateUIViewController(
      _ uiViewController: SFSafariViewController,
      context: UIViewControllerRepresentableContext<InApplicationSafariView>
    ) {
    }

  }

  extension View {
    public func safariSheet(
      isPresented: Binding<Bool>,
      url: URL
    ) -> some View {
      self.sheet(isPresented: isPresented) {
        InApplicationSafariView(url: url)
          .background(Color(uiColor: .systemBackground).edgesIgnoringSafeArea(.bottom))
      }
    }
  }
#endif
