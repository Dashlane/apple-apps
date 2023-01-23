import SwiftUI
import SwiftTreats

struct SecureLockNotificationRowView: View {
    @ObservedObject
    var model: SecureLockNotificationRowViewModel

    var body: some View {
        BaseNotificationRowView(icon: model.notification.icon,
                                title: model.notification.title,
                                description: model.notification.description,
                                reportClick: model.notification.notificationActionHandler.reportClick,
                                onTap: model.didTapOnEnableSecureLock)
            .alert(isPresented: $model.presentMPStoredInKeychainAlert) {
                Alert(title: Text(presentMPStoredInKeychainAlertTitle),
                      primaryButton: .default(Text(L10n.Localizable.kwButtonOk), action: model.enableSecureLock),
                      secondaryButton: .cancel(Text(L10n.Localizable.cancel)))
            }
            .overFullScreen(isPresented: $model.choosePinCode) {
                PinCodeSelection(model: model.pinCodeViewModel())
            }
    }

    var presentMPStoredInKeychainAlertTitle: String {
        Device.biometryType == nil ? L10n.Localizable.kwKeychainPasswordMsgPinOnly : L10n.Localizable.kwKeychainPasswordMsg(Device.currentBiometryDisplayableName)
    }
}

struct SecureLockNotificationRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SecureLockNotificationRowView(model: SecureLockNotificationRowViewModel.mock)
        }
    }
}
