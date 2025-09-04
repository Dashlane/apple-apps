import CoreKeychain
import CoreLocalization
import CoreTypes
import DesignSystem
import Foundation
import SwiftUI
import UIComponents

struct PinCodeSetupView: View {

  @StateObject
  var model: PinCodeSetupViewModel

  @State
  var showAlert = false

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(CoreL10n.loginPinSetupTitle)
        .foregroundStyle(Color.ds.text.neutral.catchy)
        .textStyle(.title.section.large)
      Text(CoreL10n.loginPinSetupMessage)
        .foregroundStyle(Color.ds.text.neutral.standard)
        .textStyle(.body.standard.regular)
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
      Button(CoreL10n.loginPinSetupCta) {
        model.choosePinCode = true
      }
      Button(CoreL10n.cancel) {
        showAlert = true
      }
      .style(mood: .brand, intensity: .quiet)
    }
    .buttonStyle(.designSystem(.titleOnly))
    .alert(isPresented: $showAlert) {
      Alert(
        title: Text(CoreL10n.Mpless.D2d.Untrusted.pinAlertTitle),
        message: Text(CoreL10n.Mpless.D2d.Untrusted.pinAlertMessage),
        primaryButton: .destructive(
          Text(CoreL10n.Mpless.D2d.Untrusted.pinAlertCancelCta),
          action: {
            model.cancel()
          }), secondaryButton: .cancel(Text(CoreL10n.Mpless.D2d.Untrusted.pinAlertDismissCta)))
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
