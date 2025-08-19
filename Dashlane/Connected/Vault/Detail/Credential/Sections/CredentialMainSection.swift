import CoreLocalization
import DesignSystem
import SwiftTreats
import SwiftUI
import UIDelight
import VaultKit

struct CredentialMainSection: View {
  @StateObject var model: CredentialMainSectionModel

  @Binding var showPasswordGenerator: Bool
  @Binding var showEmailSuggestions: Bool

  init(
    model: @escaping @autoclosure () -> CredentialMainSectionModel,
    showPasswordGenerator: Binding<Bool>,
    showEmailSuggestions: Binding<Bool>
  ) {
    self._model = .init(wrappedValue: model())
    self._showPasswordGenerator = showPasswordGenerator
    self._showEmailSuggestions = showEmailSuggestions
  }

  var body: some View {
    Section {
      if shouldShowTitle {
        titleField
      }

      if shouldShowEmail {
        emailField
      }

      if shouldShowLogin {
        loginField
      }

      if shouldShowSecondaryLogin {
        secondaryLoginField
      }

      passwordField

      if shouldShowTOTP {
        totpField
      }
    }
  }

  private var titleField: some View {
    TextDetailField(
      title: CoreL10n.KWAuthentifiantIOS.title,
      text: $model.item.title,
      placeholder: CoreL10n.KWAuthentifiantIOS.Title.placeholder
    )
    .limitedRights(model: .init(item: model.item, isFrozen: model.service.isFrozen))
    .textInputAutocapitalization(.words)
  }

  private var emailField: some View {
    TextDetailField(
      title: CoreL10n.KWAuthentifiantIOS.email,
      text: $model.item.email,
      placeholder: CoreL10n.kwEmailPlaceholder,
      actions: [
        !model.isFrozen ? .copy(model.copy) : nil,
        model.emailsSuggestions.isEmpty || !model.mode.isEditing
          ? nil
          : .other(
            title: CoreL10n.detailItemViewAccessibilitySelectEmail,
            image: .ds.action.more.outlined,
            action: { showEmailSuggestions = true }
          ),
      ].compactMap { $0 }
    )
    .actions(!model.isFrozen ? [.copy(model.copy)] : [])
    .textContentType(.emailAddress)
    .fiberFieldType(.email)
    .limitedRights(model: .init(item: model.item, isFrozen: model.service.isFrozen))
  }

  private var loginField: some View {
    TextDetailField(
      title: CoreL10n.KWAuthentifiantIOS.login,
      text: $model.item.login,
      placeholder: CoreL10n.KWAuthentifiantIOS.login,
      actions: !model.isFrozen ? [.copy(model.copy)] : []
    )
    .actions(!model.isFrozen ? [.copy(model.copy)] : [])
    .fiberFieldType(.login)
    .limitedRights(model: .init(item: model.item, isFrozen: model.service.isFrozen))
  }

  private var secondaryLoginField: some View {
    TextDetailField(
      title: shouldShowLogin
        ? CoreL10n.KWAuthentifiantIOS.secondaryLogin : CoreL10n.KWAuthentifiantIOS.login,
      text: $model.item.secondaryLogin,
      actions: !model.isFrozen ? [.copy(model.copy)] : []
    )
    .actions(!model.isFrozen ? [.copy(model.copy)] : [])
    .limitedRights(model: .init(item: model.item, isFrozen: model.service.isFrozen))
    .fiberFieldType(.secondaryLogin)
  }

  private var passwordField: some View {
    SecureDetailField(
      title: CoreL10n.KWAuthentifiantIOS.password,
      text: $model.item.password,
      onRevealAction: model.sendUsageLog,
      actions: [
        !model.isFrozen && model.sharingPermission?.canCopy != false ? .copy(model.copy) : nil,
        ![.limitedViewing, .viewing].contains(model.mode) && model.item.password.isEmpty
          ? .other(
            title: CoreL10n.kwGenerate,
            image: .ds.feature.passwordGenerator.outlined,
            action: { showPasswordGenerator = true }
          ) : nil,
      ].compactMap { $0 },
      feedback: passwordHealthAccessory
    )
    .actions(passwordFieldActions)
    .limitedRights(
      model: .init(item: model.item, isFrozen: (model.service.isFrozen && model.mode.isEditing))
    )
    .fiberFieldType(.password)
  }

  @ViewBuilder
  private var passwordHealthAccessory: some View {
    if model.mode.isEditing && shouldShowPasswordAccessory,
      model.item.metadata.sharingPermission != .limited
    {
      PasswordAccessorySection(
        model: model.passwordAccessorySectionModelFactory.make(service: model.service),
        showPasswordGenerator: $showPasswordGenerator
      )
      .padding(.trailing, 20)
    }
  }

  private var totpField: some View {
    TOTPDetailField(
      otpURL: $model.item.otpURL,
      shouldPresent2FASetupFlow: $model.isAdd2FAFlowPresented,
      actions: [.copy(model.copy)]
    ) {
      Task {
        await model.save()
      }
    }
    .actions([.copy(model.copy), .largeDisplay])
    .fiberFieldType(.otp)
    .limitedRights(model: .init(item: model.item, isFrozen: model.service.isFrozen))
  }
}

extension CredentialMainSection {

  fileprivate var shouldShowTitle: Bool {
    model.mode.isEditing
  }

  fileprivate var shouldShowEmail: Bool {
    !model.item.email.isEmpty || model.mode.isEditing
  }

  fileprivate var shouldShowLogin: Bool {
    !model.item.login.isEmpty || model.mode.isEditing && model.item.email.isEmpty
  }

  fileprivate var shouldShowSecondaryLogin: Bool {
    if !model.item.secondaryLogin.isEmpty {
      return true
    } else if model.mode == .updating {
      return !model.item.login.isEmpty || !model.item.email.isEmpty
    } else {
      return false
    }
  }

  fileprivate var shouldShowPasswordAccessory: Bool {
    (model.item.password.isEmpty && model.sharingPermission != .limited)
      || !model.item.password.isEmpty
  }

  fileprivate var shouldShowTOTP: Bool {
    model.item.otpURL != nil
      || (model.mode == .updating && !(Device.is(.mac) || model.sharingPermission == .limited))
  }

  fileprivate var passwordFieldActions: [DetailFieldActionSheet.Action] {
    var actions = [DetailFieldActionSheet.Action]()

    if model.sharingPermission?.canCopy != false && !model.isFrozen {
      actions.append(.copy(model.copy))
    }

    if model.sharingPermission?.canCopy != false {
      actions.append(.largeDisplay)
    }

    return actions
  }

}
