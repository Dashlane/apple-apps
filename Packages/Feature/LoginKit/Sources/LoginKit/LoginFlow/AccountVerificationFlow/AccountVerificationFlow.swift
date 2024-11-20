#if canImport(UIKit)
  import Foundation
  import SwiftUI
  import UIDelight
  import CoreLocalization

  struct AccountVerificationFlow: View {

    @StateObject
    var model: AccountVerificationFlowModel

    init(model: @escaping @autoclosure () -> AccountVerificationFlowModel) {
      self._model = .init(wrappedValue: model())
    }

    var body: some View {
      switch model.verificationMethod {
      case .emailToken:
        TokenVerificationView(model: model.makeTokenVerificationViewModel())
      case .totp:
        TOTPVerificationView(model: model.makeTOTPVerificationViewModel())
      }
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

#endif
