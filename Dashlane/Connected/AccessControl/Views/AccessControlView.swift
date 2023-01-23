import Foundation
import SwiftUI
import Combine
import UIDelight

struct AccessControlView<Model: AccessControlViewModelProtocol>: View {

    @ObservedObject
    var model: Model

    init(model: Model) {
        self.model = model
    }

    var body: some View {
        GravityAreaVStack(center: center,
                          bottom: KeyboardSpacer(),
                          spacing: 0)
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(.keyboard)
            .background(backgroundView)
            .alert(item: $model.error, content: alert)
    }

    @ViewBuilder
    private var center: some View {
        if let pendingAccess = model.pendingAccess, pendingAccess.error == nil {
            switch pendingAccess.mode {
            case let .masterPassword(validation):
                MasterPasswordAccessLockView(title: pendingAccess.reason,
                                             validation: validation,
                                             dismiss: model.cancel)

            case let .biometry(validation):
                Spacer()
                    .onAppear(perform: validation)

            case let .pin(validation):
                PinCodeAccessLockView(title: pendingAccess.reason,
                                      model: PinCodeAccessLockViewModel(validation: validation, dismiss: model.cancel))
            case .rememberMasterPassword:
                EmptyView()
            }
        }
    }

    private var backgroundView: some View {
        Rectangle()
            .fill(Material.ultraThinMaterial)
            .edgesIgnoringSafeArea(.all)
            .frame(maxWidth: .infinity)
            .colorScheme(.dark)
    }

    private func alert(for error: AccessControl.AuthenticationError) -> Alert {
        Alert(title: Text(L10n.Localizable.kwErrorTitle),
              message: Text(L10n.Localizable.message(for: error)),
              dismissButton: Alert.Button.default(Text(L10n.Localizable.kwButtonOk), action: self.model.cancel))
    }

}
private extension AccessControlViewModelProtocol {
    var error: AccessControl.AuthenticationError? {
        get {
            return pendingAccess?.error
        } set {
            pendingAccess?.error = newValue
        }
    }
}

private extension L10n.Localizable {
    static func message(for error: AccessControl.AuthenticationError) -> String {
        switch error {
            case .wrongMasterPassword:
                return self.kwWrongMasterPasswordMessage
            case .wrongPin:
                return self.kwWrongPinCodeMessage
        }
    }
}

struct AccessControlView_Previews: PreviewProvider {

    class FakeModel: AccessControlViewModelProtocol {
        var error: AccessControl.AuthenticationError?

        func cancel() { }

        var pendingAccess: AccessControl.PendingAccess?
        var shouldDisplayError: Bool = false

        init(mode: AccessControl.Mode) {
            self.pendingAccess = AccessControl.PendingAccess(mode: mode, reason: "Access Control")
        }
    }

    static var previews: some View {
        Group {
            AccessControlView(model: FakeModel(mode: .masterPassword { _ in }))
            AccessControlView(model: FakeModel(mode: .biometry({ })))
            AccessControlView(model: FakeModel(mode: .pin({ _ in })))
        }
    }
}
