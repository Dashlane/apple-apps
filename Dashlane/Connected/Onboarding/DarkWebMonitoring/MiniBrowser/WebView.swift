import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {

    var url: URL

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.load(URLRequest(url: url))
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(url: URL(string: "_")!)
    }
}
