import Combine
import CoreSession
import DashTypes
import DesignSystem
import Foundation
import LoginKit
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight

struct AccountEmailView: View {
  @FocusState private var isEmailFieldFocused: Bool
  @StateObject
  private var model: AccountEmailViewModel

  private var emailIsValid: Bool {
    let login = Email(self.model.email)
    return login.isValid
  }

  init(model: @autoclosure @escaping () -> AccountEmailViewModel) {
    _model = .init(wrappedValue: model())
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      self.descriptionView
      self.emailField
      Spacer()
    }
    .reportPageAppearance(.accountCreationEmail)
    .loginAppearance()
    .navigationBarBackButtonHidden(true)
    .toolbar { toolbarContent }
    .onAppear {
      isEmailFieldFocused = true
    }
  }

  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarItem(placement: .navigationBarLeading) {
      NavigationBarButton(L10n.Localizable.minimalisticOnboardingEmailFirstBack) {
        model.cancel()
      }
    }
    ToolbarItem(placement: .navigationBarTrailing) {
      if model.shouldDisplayProgress {
        IndeterminateCircularProgress()
          .frame(width: 20, height: 20)
          .padding(.horizontal, 4)
      } else {
        NavigationBarButton(
          action: {
            Task {
              await validate()
            }
          },
          label: {
            Text(L10n.Localizable.minimalisticOnboardingEmailFirstNext)
              .bold(emailIsValid)
          }
        )
        .disabled(!emailIsValid)
      }
    }
  }

  var descriptionView: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(L10n.Localizable.minimalisticOnboardingEmailFirstTitle)
        .font(DashlaneFont.custom(24, .medium).font)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.top, 56)
        .padding(.horizontal, 24)
        .foregroundColor(.ds.text.neutral.catchy)

      Text(L10n.Localizable.minimalisticOnboardingEmailFirstSubtitle)
        .font(.body)
        .foregroundColor(.ds.text.neutral.standard)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.top, 8)
        .padding(.horizontal, 24)
    }

  }

  var emailField: some View {
    DS.TextField(
      L10n.Localizable.minimalisticOnboardingEmailFirstPlaceholder,
      text: $model.email,
      actions: {
        if !model.email.isEmpty {
          DS.FieldAction.ClearContent(text: $model.email)
        }
      }
    )
    .focused($isEmailFieldFocused)
    .onSubmit {
      Task {
        await validate()
      }
    }
    .disabled(model.shouldDisplayProgress)
    .textInputAutocapitalization(.never)
    .autocorrectionDisabled()
    .textContentType(.emailAddress)
    .keyboardType(.emailAddress)
    .submitLabel(.next)
    .bubbleErrorMessage(text: $model.bubbleErrorMessage)
    .padding(.horizontal, 20)
    .padding(.top, 24)
    .alert(presenting: $model.currentAlert)
  }

  private func validate() async {
    UIApplication.shared.endEditing()
    await model.validate()
  }
}

extension AccountEmailView: NavigationBarStyleProvider {
  var navigationBarStyle: UIComponents.NavigationBarStyle {
    .transparent(tintColor: .ds.text.neutral.standard, statusBarStyle: .default)
  }
}

struct EmailView_Previews: PreviewProvider {

  static var previews: some View {
    AccountEmailView(
      model: AccountEmailViewModel(
        appAPIClient: .fake, activityReporter: .mock, completion: { _ in }))
  }
}
