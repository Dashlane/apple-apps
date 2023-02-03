#if canImport(UIKit)
import SwiftUI
import Combine
import CoreSession
import DashTypes
import UIDelight
import SwiftTreats
import UIComponents
import CoreLocalization
import DesignSystem

public struct MasterPasswordView<Model: MasterPasswordViewModel>: View {
    @ObservedObject
    var model: Model
    let showProgressIndicator: Bool

    public init(model: Model, showProgressIndicator: Bool = true) {
        self.model = model
        self.showProgressIndicator = showProgressIndicator
    }

    @State
    var accessoryHelpDisplayed: Bool = false

    @State
    var forgotButtonHelpDisplayed: Bool = false

    @FocusState
    var isTextFieldFocused: Bool

    @State
    private var logoutConfirmationDisplayed = false

    public var body: some View {
        Group {
            if model.sessionLifeCycleHandler != nil {
                mainView
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            NavigationBarButton(action: {
                                if model.isSSOUser {
                                    self.model.logout()
                                } else {
                                    logoutConfirmationDisplayed = true
                                }
                            },
                                                title: L10n.Core.kwLogOut)
                        }
                    }
                    .alert(isPresented: $logoutConfirmationDisplayed, content: {
                        Alert(title: Text(L10n.Core.askLogout),
                              message: Text(L10n.Core.signoutAskMasterPassword),
                              primaryButton: .cancel(),
                              secondaryButton: .destructive(Text(L10n.Core.kwSignOut), action: { self.model.logout() }))
                    })
            } else {
                mainView
            }
        }.onAppear {
            self.model.logOnAppear()
            #if DEBUG
            if !ProcessInfo.isTesting {
                if self.model.password.isEmpty {
                    self.model.password = TestAccount.password
                }
            }
            #endif
        }
        .loading(isLoading: model.inProgress && showProgressIndicator, loadingIndicatorOffset: true)
    }

    @ViewBuilder
    var mainView: some View {
        if Device.isIpadOrMac {
            vStackIpadMac
                .loginAppearance()
        } else {
            vStackIphone
        }
    }

    private var vStackIphone: some View {
        GravityAreaVStack(top: LoginLogo(login: self.model.login),
                          center: self.centerView,
                          bottom: self.bottomView,
                          spacing: 0)
            .loginAppearance()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationBarButton(action: {
                        Task {
                            await self.validate()
                        }
                    },
                                        title: L10n.Core.kwNext)
                        .disabled(self.model.inProgress || self.model.password.isEmpty).hidden(model.isSSOUser)
                }
            }
    }

    private var vStackIpadMac: some View {
        VStack(alignment: .center, spacing: 0) {
            LoginLogo(login: self.model.login)

            self.centerView

            HStack {
                Spacer()

                bottomView
                    .frame(alignment: .center)

                Spacer()
            }
            .padding(.top, 40)

            if !model.isExtension {
                KeyboardSpacer()
            }

            Spacer()
                .frame(maxHeight: .infinity)
        }
    }

    var centerView: some View {
        VStack(spacing: 16) {
            if !model.isSSOUser {
                passwordField
            }
            if model.biometry != nil {
                Button(action: { model.showBiometryView() }) {
                    Image(asset: model.biometry == .touchId ? Asset.fingerprint : Asset.faceId)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.ds.text.neutral.catchy)
                }
            }
        }
    }

    private var biometryImage: Image {
        if model.biometry == .touchId {
            return Asset.fingerprint.swiftUIImage
        } else {
            return Asset.faceId.swiftUIImage
        }
    }

    var bottomView: some View {
        VStack {
            if model.isSSOUser {
                Spacer()
                RoundedButton(L10n.Core.unlockWithSSOTitle, action: { model.unlockWithSSO() })
                .roundedButtonLayout(.fill)
                .padding()
            } else if Device.isIpadOrMac {
                Button(action: {
                    Task {
                        await self.validate()
                    }
                }, title: L10n.Core.kwLoginNow)
                    .buttonStyle(.login)
                    .disabled(self.model.inProgress || self.model.password.isEmpty)
            } else {
                KeyboardSpacer()
            }
        }
    }

    private var passwordField: some View {
        VStack(spacing: 20) {
            LoginFieldBox {
                TextInput(L10n.Core.kwEnterYourMasterPassword, text: $model.password) {
                    helpAccessory
                }
                .focused($isTextFieldFocused)
                .textInputIsSecure(true)
                .onSubmit {
                    Task {
                        await validate()
                    }
                }
                .disabled(model.inProgress)
                .submitLabel(.go)
                .style(intensity: .supershy)
                .shakeAnimation(forNumberOfAttempts: model.attempts)
            }

            if model.showWrongPasswordError {
                HStack {
                    Text(model.shouldSuggestMPReset ?
                            L10n.Core.resetMasterPasswordIncorrectMasterPassword1 :
                            L10n.Core.authenticationIncorrectMasterPasswordHelp1)
                        .font(.footnote) +
                        Text(" ") +
                        Text(model.shouldSuggestMPReset ?
                                L10n.Core.resetMasterPasswordIncorrectMasterPassword2 :
                                L10n.Core.authenticationIncorrectMasterPasswordHelp2)
                        .font(.footnote)
                        .underline()
                }.onTapGesture {
                    self.forgotButtonHelpDisplayed = true
                }.actionSheet(isPresented: $forgotButtonHelpDisplayed, content: helpActionSheet)
            }
        }
        .bubbleErrorMessage(text: $model.errorMessage)
        .didAppear { 
            self.isTextFieldFocused = true
        }
        .onChange(of: model.showWrongPasswordError) {
            if $0 == true {
                                DispatchQueue.main.async {
                    self.isTextFieldFocused = true
                }
            }
        }
    }

    private var helpAccessory: some View {
        Button(action: {
            self.accessoryHelpDisplayed = true
            self.model.installerLogService.login.logPasswordHelp()
        }, title: L10n.Core.resetMasterPasswordForget)
        .foregroundColor(.ds.text.brand.standard)
        .padding(5)
        .actionSheet(isPresented: $accessoryHelpDisplayed, content: helpActionSheet)
    }

    private func helpActionSheet() -> ActionSheet {
        ActionSheet(title: Text(L10n.Core.troubleLoggingIn),
                    buttons: helpActions)
    }

    private var helpActions: [ActionSheet.Button] {
        if model.shouldSuggestMPReset {
            return [
                .default(Text(L10n.Core.resetMasterPasswordConfirmationDialogConfirm), action: { model.didTapResetMP() }),
                .cancel()
            ]
        } else {
            return [
                .default(Text(L10n.Core.actionCannotLogin),
                         action: {
                            UIApplication.shared.open(DashlaneURLFactory.cannotLogin)
                            self.model.installerLogService.login.logCannotLogin()
                            self.model.logForgotPassword()
                         }),
                .default(Text(L10n.Core.actionForgotMyPassword),
                         action: {
                            UIApplication.shared.open(DashlaneURLFactory.forgotPassword)
                            self.model.installerLogService.login.logForgotPassword()
                            self.model.logForgotPassword()
                         }),
                .cancel()
            ]
        }
    }

    private func validate() async {
        UIApplication.shared.endEditing()
        await model.validate()
    }
}
#endif
