import CoreLocalization
import LoginKit
import SwiftTreats
import SwiftUI

struct SecureLockNotificationRowView: View {
  @ObservedObject
  var model: SecureLockNotificationRowViewModel

  @Environment(\.accessControl)
  var accessControl

  var body: some View {
    BaseNotificationRowView(
      icon: model.notification.icon,
      title: model.notification.title,
      description: model.notification.description,
      notificationState: model.notification.state,
      onTap: {
        accessControl.requestAccess(for: .authenticationSetup) { success in
          guard success else { return }
          model.didTapOnEnableSecureLock()
        }
      }
    )
    .alert(
      presentMPStoredInKeychainAlertTitle,
      isPresented: $model.presentMPStoredInKeychainAlert,
      actions: {
        Button(CoreL10n.kwButtonOk, action: model.enableSecureLock)
        Button(CoreL10n.cancel) {}
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
