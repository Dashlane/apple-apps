import CoreLocalization
import Foundation
import SwiftUI
import UIDelight

struct AccountVerificationFlow: View {

  @StateObject
  var model: AccountVerificationFlowModel

  init(model: @escaping @autoclosure () -> AccountVerificationFlowModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    ZStack {
      switch model.viewState {
      case .emailToken:
        TokenVerificationView(model: model.makeTokenVerificationViewModel())
      case let .totp(hasDUOPush):
        TOTPVerificationView(
          model: model.makeTOTPVerificationViewModel(pushType: hasDUOPush ? .duo : nil))
      case .initializing:
        EmptyView()
      }
    }
    .animation(.default, value: model.viewState)
  }
}

struct AccountVerificationFlow_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      AccountVerificationFlow(model: .mock(verificationMethod: .emailToken))
    }
    NavigationView {
      AccountVerificationFlow(model: .mock(verificationMethod: .totp(nil)))
    }
    NavigationView {
      AccountVerificationFlow(model: .mock(verificationMethod: .emailToken))
    }
  }
}
