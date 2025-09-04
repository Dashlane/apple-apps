import CoreLocalization
import Foundation
import SwiftUI

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
      .progressViewStyle(.indeterminate)
      .onAppear {
        Task {
          try await Task.sleep(for: .seconds(1))
          model.startLogin()
        }
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(CoreL10n.cancel) {
            model.cancel()
            dismiss()
          }
          .foregroundStyle(Color.ds.text.brand.standard)
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
        logger: .mock,
        completion: { _ in }))
  }
}
