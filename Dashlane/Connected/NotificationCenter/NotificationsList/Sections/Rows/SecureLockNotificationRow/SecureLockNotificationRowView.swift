import CoreLocalization
import LoginKit
import SwiftTreats
import SwiftUI

struct SecureLockNotificationRowView: View {
  @ObservedObject
  var model: SecureLockNotificationRowViewModel

  var body: some View {
    BaseNotificationRowView(
      icon: model.notification.icon,
      title: model.notification.title,
      description: model.notification.description,
      onTap: model.didTapOnEnableSecureLock
    )
    .alert(
      presentMPStoredInKeychainAlertTitle,
      isPresented: $model.presentMPStoredInKeychainAlert,
      actions: {
        Button(CoreLocalization.L10n.Core.kwButtonOk, action: model.enableSecureLock)
        Button(CoreLocalization.L10n.Core.cancel) {}
      }
    )
    .overFullScreen(isPresented: $model.choosePinCode) {
      PinCodeSelection(model: model.pinCodeViewModel())
    }
  }

  var presentMPStoredInKeychainAlertTitle: String {
    Device.biometryType == nil
      ? L10n.Localizable.kwKeychainPasswordMsgPinOnly
      : L10n.Localizable.kwKeychainPasswordMsg(Device.currentBiometryDisplayableName)
  }
}

struct SecureLockNotificationRowView_Previews: PreviewProvider {
  static var previews: some View {
    List {
      SecureLockNotificationRowView(model: SecureLockNotificationRowViewModel.mock)
    }
  }
}
