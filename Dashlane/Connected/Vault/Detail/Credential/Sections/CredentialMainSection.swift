import DesignSystem
import SwiftTreats
import SwiftUI
import UIDelight
import VaultKit
import CoreLocalization

struct CredentialMainSection: View {

    @ObservedObject
    var model: CredentialMainSectionModel

    @Binding
    var showPasswordGenerator: Bool

    @Binding
    var showEmailSuggestions: Bool

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
        .textInputAutocapitalization(.words)
    }

    private var emailField: some View {
        TextDetailField(
            title: CoreLocalization.L10n.Core.KWAuthentifiantIOS.email,
            text: $model.item.email,
            placeholder: CoreLocalization.L10n.Core.kwEmailPlaceholder,
            actions: [
                .copy(model.copy),
                model.emailsSuggestions.isEmpty || !model.mode.isEditing ? nil :
                        .other(
                            title: CoreLocalization.L10n.Core.detailItemViewAccessibilitySelectEmail,
                            image: .ds.action.more.outlined,
                            action: { showEmailSuggestions = true }
                        )
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
            title: shouldShowLogin ? CoreLocalization.L10n.Core.KWAuthentifiantIOS.secondaryLogin : CoreLocalization.L10n.Core.KWAuthentifiantIOS.login,
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
                    model.mode != .limitedViewing && model.item.password.isEmpty ? .other(
                        title: CoreLocalization.L10n.Core.kwGenerate,
                        image: .ds.feature.passwordGenerator.outlined,
                        action: { showPasswordGenerator = true }
                    ) : nil
                ].compactMap { $0 },
                feedback: passwordHealthAccessory
            )
            .actions(model.sharingPermission?.canCopy != false ? [.copy(model.copy), .largeDisplay] : [])
            .limitedRights(allowViewing: false, item: model.item)
            .fiberFieldType(.password)
        }
    }

    @ViewBuilder
    private var passwordHealthAccessory: some View {
        if model.mode.isEditing && shouldShowPasswordAccessory {
            PasswordAccessorySection(
                model: model.passwordAccessorySectionModelFactory.make(service: model.service),
                showPasswordGenerator: $showPasswordGenerator
            )
        }
    }

    private var totpField: some View {
        TOTPDetailField(
            otpURL: $model.item.otpURL,
            code: $model.code,
            shouldPresent2FASetupFlow: $model.isAdd2FAFlowPresented,
            actions: [.copy(model.copy)]
        ) {
            model.save()
        }
        .actions([.copy(model.copy), .largeDisplay])
        .fiberFieldType(.otp)
        .limitedRights(item: model.item)
    }
}

private extension CredentialMainSection {

    var shouldShowTitle: Bool {
        model.mode.isEditing
    }

    var shouldShowEmail: Bool {
        !model.item.email.isEmpty || model.mode.isEditing
    }

    var shouldShowLogin: Bool {
        !model.item.login.isEmpty || model.mode.isEditing && model.item.email.isEmpty
    }

    var shouldShowSecondaryLogin: Bool {
        if !model.item.secondaryLogin.isEmpty {
            return true
        } else if model.mode == .updating {
            return !model.item.login.isEmpty || !model.item.email.isEmpty
        } else {
            return false
        }
    }

    var shouldShowPasswordAccessory: Bool {
        (model.item.password.isEmpty && model.sharingPermission != .limited) || !model.item.password.isEmpty
    }

    var shouldShowTOTP: Bool {
        model.item.otpURL != nil || (model.mode == .updating && !(Device.isMac || model.sharingPermission == .limited))
    }
}
