import Foundation
import SwiftUI
import Combine
import TOTPGenerator
import UIDelight
import UIComponents
import DesignSystem
import VaultKit
import CoreLocalization

struct AddOTPSecretKeyView: View, NavigationBarStyleProvider {
    var navigationBarStyle: UIComponents.NavigationBarStyle = .hidden(statusBarStyle: .default)

    @StateObject
    var model: AddOTPSecretViewModel

    init(viewModel: @autoclosure @escaping () -> AddOTPSecretViewModel) {
        self._model = .init(wrappedValue: viewModel())
    }

    @FocusState
    private var isTextFieldFocused: Bool

    var body: some View {

        VStack(alignment: .leading) {
            Spacer()

            Text(L10n.Localizable._2faSetupIntroTitle(model.credential.title)).font(.custom(GTWalsheimPro.regular.name, size: 26, relativeTo: .title))
            textField
            Spacer()
            RoundedButton(CoreLocalization.L10n.Core.kwNext, action: model.validate)
                .roundedButtonLayout(.fill)
                .disabled(model.otpSecretKey.isEmpty)
        }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarStyle(.transparent)
            .reportPageAppearance(.toolsAuthenticatorSetupTextCode)

    }

    var textField: some View {
        TextField(L10n.Localizable._2faSetupIntroSetupWithCode, text: $model.otpSecretKey)
            .onSubmit(model.validate)
            .focused($isTextFieldFocused)
            .submitLabel(.next)
            .padding(16)
            .font(.callout)
            .frame(height: 48)
            .background(Color.ds.container.expressive.neutral.quiet.idle)
    }
}

struct AddOTPTokenView_Previews: PreviewProvider {

    static var previews: some View {
        AddOTPSecretKeyView(viewModel: AddOTPSecretViewModel(credential: PersonalDataMock.Credentials.amazon, completion: { _ in }))
    }
}
