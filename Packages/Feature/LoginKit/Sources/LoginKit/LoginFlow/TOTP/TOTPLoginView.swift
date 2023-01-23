#if canImport(UIKit)
import Foundation
import SwiftUI
import Combine
import CoreSession
import UIDelight
import SwiftTreats
import DashTypes
import CoreNetworking
import UIComponents
import DesignSystem
import CoreLocalization

public struct TOTPLoginView<Model: TOTPLoginViewModel>: View {

    @StateObject var model: Model

    @Environment(\.dismiss)
    private var dismiss

    public init(model: @autoclosure @escaping () -> Model) {
        self._model = .init(wrappedValue: model())
    }

    @FocusState
    var isTextFieldFocused: Bool

    @State
    var isLostOTPSheetDisplayed = false

    public var body: some View {
        ZStack {
            if model.showDuoPush {
                duoPushView.navigationBarHidden(true)
            } else if model.showAuthenticatorPush {
                AuthenticatorPushView(model: model.makeAuthenticatorPushViewModel(), fallbackOptionTitle: L10n.Core.authenticatorTotpPushOption)
            } else {
                totpView
                    .loginAppearance()
                    .navigationTitle(L10n.Core.kwLoginVcLoginButton)
                    .loading(isLoading: model.inProgress, loadingIndicatorOffset: true)
                    .onAppear {
                        self.model.logOnAppear()
                    }
                    .toolbar { ToolbarItem(placement: .navigationBarLeading) { backButton } }
                    .navigationBarBackButtonHidden(true)
            }
        }.animation(.default, value: model.showDuoPush)
    }

    @ViewBuilder
    var backButton: some View {
        switch model.context {
        case .passwordApp:
            BackButton(label: L10n.Core.kwBack,
                       color: .ds.text.neutral.catchy,
                       action: dismiss.callAsFunction)
        case let .autofillExtension(cancelAction):
            Button(action: {
                cancelAction()
            }, title: L10n.Core.cancel)
            .foregroundColor(.ds.text.neutral.standard)
        }
    }

    private var duoPushView: some View {
        GravityAreaVStack(top: LoginLogo(login: nil),
                          center: Text(L10n.Core.duoChallengePrompt),
                          bottom: Spacer(),
                          spacing: 0)
            .edgesIgnoringSafeArea(.all)
            .loginAppearance()
            .onAppear {
                Task {
                    await self.model.sendPush(.duo)
                }
            }
            .loading(isLoading: true, loadingIndicatorOffset: true)
    }
    
    @ViewBuilder
    private var totpView: some View {
        Group {
            if Device.isIpadOrMac {
                vStackIpadMac
            } else {
                vStackIphone
            }
        }
        .modifier(LostOTPSheetModifier(isLostOTPSheetDisplayed: $isLostOTPSheetDisplayed,
                                       useBackupCode: { model.useBackupCode($0) },
                                       lostOTPSheetViewModel: model.lostOTPSheetViewModel))
    }

    private var vStackIphone: some View {
        GravityAreaVStack(top: LoginLogo(login: self.model.login),
                          center: self.calloutAndCodeField,
                          bottom: VStack {
                            self.sendDuoPushButton.hidden(!self.model.hasDuoPush)
            self.sendAuthenticatorPushButton.hidden(!self.model.hasAuthenticatorPush)
                            KeyboardSpacer()
                          },
                          spacing: 0)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationBarButton(action: self.validate,
                                    title: L10n.Core.kwNext)
                    .disabled(!self.model.canLogin)
            }
        }
    }

    private var vStackIpadMac: some View {
        VStack(alignment: .center, spacing: 0) {
            LoginLogo(login: self.model.login)

            calloutAndCodeField

            HStack {
                Spacer()

                Button(action: validate, title: L10n.Core.kwNext)
                    .buttonStyle(.login)
                    .frame(alignment: .center)
                    .disabled(!self.model.canLogin)

                Spacer()
            }
            .padding(.top, 40)

            KeyboardSpacer()

            Spacer()
                .frame(maxHeight: .infinity)
        }
    }

    private var calloutAndCodeField: some View {
        VStack {
            HStack {
            Text(L10n.Core.kwOtpMessage)
                .font(.callout)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                Spacer()
            }.padding(.horizontal)
            LoginFieldBox {
                TextInput(L10n.Core.kwOtpPlaceholderText,
                          text: $model.otp)
                .focused($isTextFieldFocused)
                .onSubmit {
                    self.validate()
                }
                .style(intensity: .supershy)
                .keyboardType(.numberPad)
                .textInputAutocapitalization(.never)
                .submitLabel(.continue)
                .disabled(model.inProgress)
            }
            .bubbleErrorMessage(text: $model.errorMessage)
            HStack {
                Button(action: {
                    isLostOTPSheetDisplayed = true
                }, label: {
                    Text(L10n.Core.otpRecoveryCannotAccessCodes)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.ds.text.neutral.standard)
                        .underline()
                })
                Spacer()
            }.padding(.horizontal)
            .onAppear {
                self.isTextFieldFocused = true
            }
        }
    }

    private var sendDuoPushButton: some View {
        Button(action: {
            self.model.showDuoPush = true
        }, title: L10n.Core.duoChallengeButton)
        .foregroundColor(.ds.text.brand.standard)
        .padding(5)
    }

    private var sendAuthenticatorPushButton: some View {
        Button(action: {
            self.model.showAuthenticatorPush = true
        }, title: L10n.Core.authenticatorPushChallengeButton)
        .foregroundColor(.ds.text.brand.standard)
        .padding(5)
    }
    
    private func validate() {
        UIApplication.shared.endEditing()
        model.validate()
    }

}

struct TOTPLoginView_Previews: PreviewProvider {

    class TOTPLoginViewModelMock: TOTPLoginViewModel {
        func makeAuthenticatorPushViewModel() -> AuthenticatorPushViewModel {
            AuthenticatorPushViewModel(login: login, validator: {}, completion: {_ in})
        }
        
        var hasAuthenticatorPush: Bool
        
        var showAuthenticatorPush: Bool
        
        let context: LocalLoginFlowContext = .passwordApp

        let login: Login = Login("_")

        @Published
        var otp: String = ""

        var errorMessage: String?

        let inProgress: Bool = false

        let hasDuoPush: Bool

        var showDuoPush: Bool

        let loginInstallerLogger: LoginInstallerLogger = LoginInstallerLogger(installerLogService: FakeInstallerLogService())

        let lostOTPSheetViewModel: LostOTPSheetViewModel = LostOTPSheetViewModel(recover2faService: Recover2FAWebService(webService: LegacyWebServiceMock(response: ""), login: .init("_")))

        func validate() {}

        func sendPush(_ type: PushType) async {}

        func logOnAppear() {}

        func useBackupCode(_ code: String) {}
        
        init(hasDuoPush: Bool = false,
             showDuoPush: Bool = false,
             hasAuthenticatorPush: Bool = false,
             showAuthenticatorPush: Bool = false) {
            self.hasDuoPush = hasDuoPush
            self.showDuoPush = showDuoPush
            self.hasAuthenticatorPush = hasAuthenticatorPush
            self.showAuthenticatorPush = showAuthenticatorPush
        }

    }

    static var previews: some View {
        Group {
            TOTPLoginView.init(model: TOTPLoginViewModelMock())
            TOTPLoginView.init(model: TOTPLoginViewModelMock(hasDuoPush: true))
            TOTPLoginView.init(model: TOTPLoginViewModelMock(hasDuoPush: true, showDuoPush: true))
        }
    }
}
#endif
