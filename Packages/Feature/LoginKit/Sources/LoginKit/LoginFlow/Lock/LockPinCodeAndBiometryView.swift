#if canImport(UIKit)
import Foundation
import SwiftUI
import Combine
import CoreSession
import UIDelight
import DashTypes
import UIComponents
import CoreLocalization

public struct LockPinCodeAndBiometryView<Model: PinCodeAndBiometryViewModel>: View {
    @StateObject
    var model: Model

    public init(model: @autoclosure @escaping () -> Model) {
        self._model = .init(wrappedValue: model())
    }

    public var body: some View {
        VStack(alignment: .center) {
            LoginLogo(login: model.login)
                .fixedSize(horizontal: false, vertical: true)
            content
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
                        cancelAction: { model.cancel() })
                .frame(maxHeight: .infinity)
                .padding(.bottom, 30)
                .padding(.horizontal, 40)
        }
    }
}

struct LoginPinCodeView_Previews: PreviewProvider {

    class FakePincodeModel: PinCodeAndBiometryViewModel {
        func logOnAppear() {}
        var loading: Bool = false
        var biometricAuthenticationInProgress: Bool = false
        var pincode: String
        var attempts: Int = 0
        let login: Login
        init(login: Login, pincode: String = "") {
            self.login = login
            self.pincode = pincode
        }
        func cancel() {}
    }

    static var previews: some View {
        MultiContextPreview {
            Group {
                LockPinCodeAndBiometryView(model: FakePincodeModel(login: Login("_"), pincode: "123"))
                LockPinCodeAndBiometryView(model: FakePincodeModel(login: Login("Hello"))).frame(width: 260, height: 418)
                LockPinCodeAndBiometryView(model: FakePincodeModel(login: Login("Hello"))).frame(width: 300, height: 450)
                LockPinCodeAndBiometryView(model: FakePincodeModel(login: Login("Hello"))).frame(width: 400, height: 650)
            }
        }.previewLayout(.sizeThatFits)
    }
}
#endif
