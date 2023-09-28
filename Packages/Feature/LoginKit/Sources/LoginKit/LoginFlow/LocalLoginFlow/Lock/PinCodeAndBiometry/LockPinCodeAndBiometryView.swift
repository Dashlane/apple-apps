#if canImport(UIKit)
import Foundation
import SwiftUI
import Combine
import CoreSession
import UIDelight
import DashTypes
import UIComponents
import CoreLocalization
import DesignSystem

public struct LockPinCodeAndBiometryView: View {
    @StateObject
    var model: LockPinCodeAndBiometryViewModel

    public init(model: @autoclosure @escaping () -> LockPinCodeAndBiometryViewModel) {
        self._model = .init(wrappedValue: model())
    }

    public var body: some View {
        VStack(alignment: .center) {
            LoginLogo(login: model.login)
                .fixedSize(horizontal: false, vertical: true)
            content
            if model.accountType.canFallbackFromPinCode {
                RoundedButton(L10n.Core.Unlock.Pincode.forgotButton) {
                    model.recover()
                }
                .style(mood: .brand, intensity: .supershy)
            }
        }
        .animation(.spring(), value: model.biometricAuthenticationInProgress)
        .loginAppearance()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton(label: L10n.Core.kwBack,
                           color: .ds.text.neutral.catchy,
                           action: { model.cancel() })
            }
        }
        .onAppear { self.model.logOnAppear() }
        .loading(isLoading: model.loading)
    }

    @ViewBuilder
    var content: some View {
        if model.biometricAuthenticationInProgress {
            Spacer()
        } else {
            PinCodeView(pinCode: $model.pincode,
                        attempt: model.attempts,
                        hideCancel: true,
                        cancelAction: {  })
                .frame(maxHeight: .infinity)
                .padding(.bottom, 30)
                .padding(.horizontal, 40)
        }
    }
}

struct LoginPinCodeView_Previews: PreviewProvider {

    static var previews: some View {
        LockPinCodeAndBiometryView(model: .mock)
    }
}

private extension AccountType {
    var canFallbackFromPinCode: Bool {
        switch self {
        case .masterPassword:
            return false
        case .invisibleMasterPassword:
            return true
        case .sso:
            return false
        }
    }
}
#endif
