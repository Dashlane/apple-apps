import Foundation
import SwiftUI
import UserTrackingFoundation

public struct SSOLocalLoginView: View {

  @StateObject
  var model: SSOLocalLoginViewModel

  @Environment(\.report)
  var report

  public init(model: @autoclosure @escaping () -> SSOLocalLoginViewModel) {
    self._model = .init(wrappedValue: model())
  }

  public var body: some View {
    SSOView(model: model.makeSSOViewModel())
      .onAppear {
        report?(
          UserEvent.AskAuthentication(
            mode: .sso,
            reason: .login,
            verificationMode: Definition.VerificationMode.none))
      }
      .reportPageAppearance(.loginSso)
  }
}

struct SSOLocalLoginView_Previews: PreviewProvider {
  static var previews: some View {
    SSOLocalLoginView(model: .mock)
  }
}
