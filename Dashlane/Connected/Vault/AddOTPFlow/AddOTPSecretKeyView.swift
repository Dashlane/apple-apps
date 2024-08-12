import Combine
import CoreLocalization
import DesignSystem
import Foundation
import SwiftUI
import TOTPGenerator
import UIComponents
import UIDelight
import VaultKit

struct AddOTPSecretKeyView: View {

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

      Text(L10n.Localizable._2faSetupIntroTitle(model.credential.title)).font(
        .custom(GTWalsheimPro.regular.name, size: 26, relativeTo: .title))
      textField
      Spacer()
      Button(CoreLocalization.L10n.Core.kwNext, action: model.validate)
        .buttonStyle(.designSystem(.titleOnly))
        .disabled(model.otpSecretKey.isEmpty)
    }
    .padding(.horizontal, 24)
    .padding(.vertical, 24)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    AddOTPSecretKeyView(
      viewModel: AddOTPSecretViewModel(
        credential: PersonalDataMock.Credentials.amazon, completion: { _ in }))
  }
}
