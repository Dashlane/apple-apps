import SwiftTreats
import SwiftUI
import WebKit

#if canImport(UIKit)
  struct SSOWebView: UIViewRepresentable {
    typealias SAMLCompletion = ((Result<String, Error>) -> Void)
    typealias CallBackCompletion = ((Result<URL, Error>) -> Void)

    let url: URL
    let injectionScript: String?
    let didReceiveCallback: CallBackCompletion?
    let didReceiveSAML: SAMLCompletion?

    init(
      url: URL,
      injectionScript: String? = nil,
      didReceiveCallback: CallBackCompletion? = nil,
      didReceiveSAML: SAMLCompletion? = nil
    ) {
      self.url = url
      self.injectionScript = injectionScript
      self.didReceiveCallback = didReceiveCallback
      self.didReceiveSAML = didReceiveSAML
      deleteCookies()
    }

    func deleteCookies() {
      HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
      WKWebsiteDataStore.default().fetchDataRecords(
        ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()
      ) { records in
        records.forEach { record in
          WKWebsiteDataStore.default().removeData(
            ofTypes: record.dataTypes, for: [record], completionHandler: {})
        }
      }
    }

    func makeUIView(context: Context) -> WKWebView {
      let userContentController = WKUserContentController()
      let configuration = WKWebViewConfiguration()

      if let script = injectionScript {
        let injectionScript = WKUserScript(
          source: script, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        userContentController.addUserScript(injectionScript)
        userContentController.add(context.coordinator, name: "didReceiveSAML")
        configuration.userContentController = userContentController
      }

      let view = WKWebView(frame: .zero, configuration: configuration)
      let delegate = context.coordinator
      view.navigationDelegate = delegate
      view.load(URLRequest(url: url))
      return view
    }

    func makeCoordinator() -> Coordinator {
      Coordinator(didReceiveCallback: didReceiveCallback, didReceiveSAML: didReceiveSAML)
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

  }
#else
  struct SSOWebView: NSViewRepresentable {

    let url: URL
    let injectionScript: String?
    let didReceiveCallback: Completion<URL>?
    let didReceiveSAML: Completion<String>?

    init(
      url: URL, injectionScript: String? = nil, didReceiveCallback: Completion<URL>? = nil,
      didReceiveSAML: Completion<String>? = nil
    ) {
      self.url = url
      self.injectionScript = injectionScript
      self.didReceiveCallback = didReceiveCallback
      self.didReceiveSAML = didReceiveSAML
      URLCache.shared.removeAllCachedResponses()
      if let cookies = HTTPCookieStorage.shared.cookies {
        for cookie in cookies {
          HTTPCookieStorage.shared.deleteCookie(cookie)
        }
      }
    }

    func makeNSView(context: Context) -> WKWebView {
      let userContentController = WKUserContentController()
      let configuration = WKWebViewConfiguration()

      if let script = injectionScript {
        let injectionScript = WKUserScript(
          source: script, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        userContentController.addUserScript(injectionScript)
        userContentController.add(context.coordinator, name: "didReceiveSAML")
        configuration.userContentController = userContentController
      }

      let view = WKWebView(frame: .zero, configuration: configuration)
      let delegate = context.coordinator
      view.navigationDelegate = delegate
      view.load(URLRequest(url: url))
      return view
    }

    func makeCoordinator() -> Coordinator {
      Coordinator(didReceiveCallback: didReceiveCallback, didReceiveSAML: didReceiveSAML)
    }

    func updateNSView(_ uiView: WKWebView, context: Context) {}

  }

#endif

@MainActor
class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
  let didReceiveCallback: Completion<URL>?
  let didReceiveSAML: Completion<String>?

  init(didReceiveCallback: Completion<URL>?, didReceiveSAML: Completion<String>?) {
    self.didReceiveCallback = didReceiveCallback
    self.didReceiveSAML = didReceiveSAML
  }

  nonisolated func userContentController(
    _ userContentController: WKUserContentController, didReceive message: WKScriptMessage
  ) {
    Task { @MainActor in
      guard let response = message.body as? String else {
        return
      }
      didReceiveSAML?(.success(response))
    }
  }

  nonisolated func webView(
    _ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!
  ) {
    Task { @MainActor in
      guard let url = webView.url, url.absoluteString.hasPrefix("dashlane") == true else {
        return
      }
      didReceiveCallback?(.success(url))
    }
  }

  nonisolated func webView(
    _ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error
  ) {
    Task { @MainActor in
      didReceiveSAML?(.failure(error))
      didReceiveCallback?(.failure(error))
    }
  }

  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async
    -> WKNavigationActionPolicy
  {
    return .allow
  }
}

struct SSOWebView_Previews: PreviewProvider {
  static var previews: some View {
    SSOWebView(url: URL(string: "_")!)
  }
}
