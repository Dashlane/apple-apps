import Foundation
import SwiftUI
import UserTrackingFoundation

public struct SSORemoteLoginView: View {

  @StateObject
  var model: SSORemoteLoginViewModel

  @Environment(\.report)
  var report

  public init(model: @autoclosure @escaping () -> SSORemoteLoginViewModel) {
    self._model = .init(wrappedValue: model())
  }

  public var body: some View {
    SSOView(model: model.makeSSOViewModel())
      .onAppear {
        report?(
          UserEvent.AskAuthentication(
            mode: .sso, reason: .login, verificationMode: Definition.VerificationMode.none))
      }
      .reportPageAppearance(.loginSso)
  }
}

struct SSORemoteLoginView_Previews: PreviewProvider {
  static var previews: some View {
    SSORemoteLoginView(model: .mock)
  }
}
