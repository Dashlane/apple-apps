#if canImport(UIKit)
  import Foundation
  import SwiftUI
  import CoreLocalization
  import DesignSystem
  import UIComponents
  import CoreKeychain
  import DashTypes

  struct PinCodeSetupView: View {

    @StateObject
    var model: PinCodeSetupViewModel

    @State
    var showAlert = false

    var body: some View {
      VStack(alignment: .leading, spacing: 12) {
        Text(L10n.Core.loginPinSetupTitle)
          .font(
            .custom(
              GTWalsheimPro.regular.name,
              size: 28,
              relativeTo: .title
            )
            .weight(.medium))
        Text(L10n.Core.loginPinSetupMessage)
          .font(.body)
        Spacer()
        buttonsView
      }.padding(24)
        .fullScreenCover(isPresented: $model.choosePinCode) {
          PinCodeSelection(model: model.makePinCodeViewModel())
        }
        .loginAppearance()
        .navigationBarBackButtonHidden()
        .reportPageAppearance(.loginDeviceTransferSetPin)
    }

    var buttonsView: some View {
      VStack(spacing: 8) {
        Spacer()
        Button(L10n.Core.loginPinSetupCta) {
          model.choosePinCode = true
        }
        Button(L10n.Core.cancel) {
          showAlert = true
        }
        .style(mood: .brand, intensity: .quiet)
      }
      .buttonStyle(.designSystem(.titleOnly))
      .alert(isPresented: $showAlert) {
        Alert(
          title: Text(L10n.Core.Mpless.D2d.Untrusted.pinAlertTitle),
          message: Text(L10n.Core.Mpless.D2d.Untrusted.pinAlertMessage),
          primaryButton: .destructive(
            Text(L10n.Core.Mpless.D2d.Untrusted.pinAlertCancelCta),
            action: {
              model.cancel()
            }), secondaryButton: .cancel(Text(L10n.Core.Mpless.D2d.Untrusted.pinAlertDismissCta)))
      }
    }
  }

  struct PinCodeSetupView_Previews: PreviewProvider {
    static var previews: some View {
      PinCodeSetupView(model: PinCodeSetupViewModel(login: Login(""), completion: { _ in }))
      PinCodeSetupView(
        model: PinCodeSetupViewModel(login: Login(""), completion: { _ in }), showAlert: true)
    }
  }
#endif
