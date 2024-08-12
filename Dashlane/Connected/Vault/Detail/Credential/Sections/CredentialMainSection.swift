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
      title: CoreLocalization.L10n.Core.KWAuthentifiantIOS.title,
      text: $model.item.title,
      placeholder: CoreLocalization.L10n.Core.KWAuthentifiantIOS.Title.placeholder
    )
    .limitedRights(item: model.item)
    .textInputAutocapitalization(.words)
  }

  private var emailField: some View {
    TextDetailField(
      title: CoreLocalization.L10n.Core.KWAuthentifiantIOS.email,
      text: $model.item.email,
      placeholder: CoreLocalization.L10n.Core.kwEmailPlaceholder,
      actions: [
        .copy(model.copy),
        model.emailsSuggestions.isEmpty || !model.mode.isEditing
          ? nil
          : .other(
            title: CoreLocalization.L10n.Core.detailItemViewAccessibilitySelectEmail,
            image: .ds.action.more.outlined,
            action: { showEmailSuggestions = true }
          ),
      ].compactMap { $0 }
    )
    .actions([.copy(model.copy)])
    .textContentType(.emailAddress)
    .fiberFieldType(.email)
    .limitedRights(item: model.item)
  }

  private var loginField: some View {
    TextDetailField(
      title: CoreLocalization.L10n.Core.KWAuthentifiantIOS.login,
      text: $model.item.login,
      placeholder: CoreLocalization.L10n.Core.KWAuthentifiantIOS.login,
      actions: [.copy(model.copy)]
    )
    .actions([.copy(model.copy)])
    .fiberFieldType(.login)
    .limitedRights(item: model.item)
  }

  private var secondaryLoginField: some View {
    TextDetailField(
      title: shouldShowLogin
        ? CoreLocalization.L10n.Core.KWAuthentifiantIOS.secondaryLogin
        : CoreLocalization.L10n.Core.KWAuthentifiantIOS.login,
      text: $model.item.secondaryLogin,
      actions: [.copy(model.copy)]
    )
    .actions([.copy(model.copy)])
    .limitedRights(item: model.item)
    .fiberFieldType(.secondaryLogin)
  }

  private var passwordField: some View {
    VStack(spacing: 4) {
      SecureDetailField(
        title: CoreLocalization.L10n.Core.KWAuthentifiantIOS.password,
        text: $model.item.password,
        shouldReveal: $model.shouldReveal,
        onRevealAction: model.reveal,
        isColored: true,
        actions: [
          model.sharingPermission?.canCopy != false ? .copy(model.copy) : nil,
          model.mode != .limitedViewing && model.item.password.isEmpty
            ? .other(
              title: CoreLocalization.L10n.Core.kwGenerate,
              image: .ds.feature.passwordGenerator.outlined,
              action: { showPasswordGenerator = true }
            ) : nil,
        ].compactMap { $0 },
        feedback: passwordHealthAccessory
      )
      .actions(model.sharingPermission?.canCopy != false ? [.copy(model.copy), .largeDisplay] : [])
      .limitedRights(item: model.item)
      .fiberFieldType(.password)
    }
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
    }
  }

  private var totpField: some View {
    TOTPDetailField(
      otpURL: $model.item.otpURL,
      code: $model.totpCode,
      progress: $model.totpProgress,
      shouldPresent2FASetupFlow: $model.isAdd2FAFlowPresented,
      actions: [.copy(model.copy)]
    ) {
      Task {
        await model.save()
      }
    }
    .actions([.copy(model.copy), .largeDisplay])
    .fiberFieldType(.otp)
    .limitedRights(item: model.item)
    .onAppear { model.startTotpUpdates() }
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
      || (model.mode == .updating && !(Device.isMac || model.sharingPermission == .limited))
  }
}
