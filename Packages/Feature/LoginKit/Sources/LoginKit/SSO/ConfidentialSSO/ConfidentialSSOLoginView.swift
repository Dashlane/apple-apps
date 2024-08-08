#if canImport(UIKit)
  import Foundation
  import SwiftUI
  import CoreSession
  import DashlaneAPI
  import CoreLocalization

  public struct ConfidentialSSOView: View {

    @StateObject
    var model: ConfidentialSSOViewModel

    public init(model: @autoclosure @escaping () -> ConfidentialSSOViewModel) {
      self._model = .init(wrappedValue: model())
    }

    public var body: some View {
      ZStack {
        if let loginInfo = model.loginService {
          SSOWebView(
            url: loginInfo.authorisationURL,
            injectionScript: loginInfo.injectionScript,
            didReceiveSAML: model.didReceiveSAML)
        } else {
          ProgressView()
        }
      }
      .animation(.default, value: model.loginService)
      .navigationBarBackButtonHidden()
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(CoreLocalization.L10n.Core.cancel) {
            model.cancel()
          }
          .foregroundColor(.ds.text.brand.standard)
        }
      }
    }
  }

  struct ConfidentialSSOView_Previews: PreviewProvider {
    static var previews: some View {
      ConfidentialSSOView(
        model: ConfidentialSSOViewModel(
          login: "_",
          nitroClient: .fake,
          completion: { _ in }))
    }
  }
#endif
