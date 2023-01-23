import SwiftTreats
import SwiftUI
import UIDelight

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
            title: L10n.Localizable.KWAuthentifiantIOS.title,
            text: $model.item.title,
            placeholder: L10n.Localizable.KWAuthentifiantIOS.Title.placeholder,
            placeholderColor: FiberAsset.alternativePlaceholder.color
        )
        .textInputAutocapitalization(.words)
    }

    private var emailField: some View {
        TextDetailField(
            title: L10n.Localizable.KWAuthentifiantIOS.email,
            text: $model.item.email,
            placeholder: L10n.Localizable.kwEmailPlaceholder,
            placeholderColor: FiberAsset.alternativePlaceholder.color
        )
        .actions([.copy(model.copy)])
        .textContentType(.emailAddress)
        .fiberFieldType(.email)
        .suggestion(
            value: $model.item.email,
            suggestions: model.emailsSuggestions,
            showSuggestions: $showEmailSuggestions
        )
        .limitedRights(item: model.item)
    }

    private var loginField: some View {
        TextDetailField(
            title: L10n.Localizable.KWAuthentifiantIOS.login,
            text: $model.item.login,
            placeholder: L10n.Localizable.KWAuthentifiantIOS.login,
            placeholderColor: FiberAsset.alternativePlaceholder.color
        )
        .actions([.copy(model.copy)])
        .fiberFieldType(.login)
        .limitedRights(item: model.item)
    }

    private var secondaryLoginField: some View {
        TextDetailField(
            title: shouldShowLogin ? L10n.Localizable.KWAuthentifiantIOS.secondaryLogin : L10n.Localizable.KWAuthentifiantIOS.login,
            text: $model.item.secondaryLogin
        )
        .actions([.copy(model.copy)])
        .limitedRights(item: model.item)
        .fiberFieldType(.secondaryLogin)
    }

    private var passwordField: some View {
        VStack(spacing: 4) {
                        SecureDetailField(
                title: L10n.Localizable.KWAuthentifiantIOS.password,
                placeholderColor: FiberAsset.alternativePlaceholder.color,
                text: $model.item.password,
                shouldReveal: $model.shouldReveal,
                action: model.reveal,
                isColored: true
            )
            .actions(model.sharingPermission?.canCopy != false ? [.copy(model.copy), .largeDisplay] : [])
            .limitedRights(allowViewing: false, item: model.item)
            .fiberFieldType(.password)

                        if model.mode.isEditing && shouldShowPasswordAccessory {
                passwordHealthAccessory
            }
        }
    }

    private var passwordHealthAccessory: some View {
        PasswordAccessorySection(
            model: model.passwordAccessorySectionModelFactory.make(service: model.service),
            showPasswordGenerator: $showPasswordGenerator
        )
    }

    private var totpField: some View {
        TOTPDetailField(
            otpURL: $model.item.otpURL,
            code: $model.code,
            shouldPresent2FASetupFlow: $model.isAdd2FAFlowPresented
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
