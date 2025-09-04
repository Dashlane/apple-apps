import Combine
import CoreLocalization
import CoreSession
import CoreTypes
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
      Button(L10n.Localizable.minimalisticOnboardingEmailFirstBack) {
        model.cancel()
      }
    }
    ToolbarItem(placement: .navigationBarTrailing) {
      if model.shouldDisplayProgress {
        IndeterminateCircularProgress()
          .frame(width: 20, height: 20)
          .padding(.horizontal, 4)
      } else {
        Button(
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
        .textStyle(.title.section.medium)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.top, 56)
        .padding(.horizontal, 24)
        .foregroundStyle(Color.ds.text.neutral.catchy)

      Text(L10n.Localizable.minimalisticOnboardingEmailFirstSubtitle)
        .textStyle(.body.standard.regular)
        .foregroundStyle(Color.ds.text.neutral.standard)
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
      },
      feedback: {
        if let errorMessage = model.bubbleErrorMessage {
          FieldTextualFeedback(errorMessage)
            .style(.error)
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
    .padding(.horizontal, 20)
    .padding(.top, 24)
    .alert(
      Text(CoreL10n.validityStatusExpiredVersionNoUpdateTitle),
      isPresented: $model.showVersionInvalidAlert,
      actions: {
        Button(CoreL10n.validityStatusExpiredVersionNoUpdateClose, role: .cancel) {}
      }, message: { Text(CoreL10n.validityStatusExpiredVersionNoUpdateDesc) })

  }

  private func validate() async {
    UIApplication.shared.endEditing()
    await model.validate()
  }
}

struct EmailView_Previews: PreviewProvider {

  static var previews: some View {
    AccountEmailView(
      model: AccountEmailViewModel(
        appAPIClient: .fake, activityReporter: .mock, completion: { _ in }))
  }
}
