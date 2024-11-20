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
        switch model.viewState {
        case let .sso(authorisationURL, injectionScript):
          SSOWebView(
            url: authorisationURL,
            injectionScript: injectionScript,
            didReceiveSAML: model.didReceiveSAML)
        case .inProgress:
          ProgressView()
        }
      }
      .animation(.default, value: model.viewState)
      .navigationBarBackButtonHidden()
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(CoreLocalization.L10n.Core.cancel) {
            Task {
              try await model.cancel()
            }
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
          logger: .mock,
          completion: { _ in }))
    }
  }
#endif
