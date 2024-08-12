#if canImport(UIKit)
  import Foundation
  import SwiftUI
  import CoreLocalization

  public struct SelfHostedSSOView: View {

    @StateObject
    var model: SelfHostedSSOViewModel

    @Environment(\.dismiss)
    var dismiss

    public init(model: @escaping @autoclosure () -> SelfHostedSSOViewModel) {
      self._model = .init(wrappedValue: model())
    }

    public var body: some View {
      ProgressView()
        .navigationBarBackButtonHidden()
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button(L10n.Core.cancel) {
              model.cancel()
              dismiss()
            }
            .foregroundColor(.ds.text.brand.standard)
          }
        }
    }
  }

  struct SSOView_Previews: PreviewProvider {
    static var previews: some View {
      SelfHostedSSOView(
        model: SelfHostedSSOViewModel(
          login: "_",
          authorisationURL: URL(string: "_")!,
          completion: { _ in }))
    }
  }

#endif
