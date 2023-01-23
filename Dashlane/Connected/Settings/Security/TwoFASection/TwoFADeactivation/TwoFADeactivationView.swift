import SwiftUI
import CoreSession
import CoreNetworking
import DashTypes
import CoreLocalization
import UIComponents
import DesignSystem
import Combine
import LoginKit

struct TwoFADeactivationView: View {

    @StateObject
    var model: TwoFADeactivationViewModel

    init(model: @autoclosure @escaping () -> TwoFADeactivationViewModel) {
        self._model = .init(wrappedValue: model())
    }

    @State
    var isLostOTPSheetDisplayed = false

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                switch model.state {
                case .otpInput:
                    mainView
                case .inProgress:
                    TwoFAProgressView(state: $model.progressState)
                case .failure:
                    errorView
                case .twoFAEnforced:
                    enforcementView
                }
            }
            .frame(maxWidth: .infinity)
            .onReceive(model.dismissPublisher) {
                dismiss()
            }
            .animation(.default, value: model.state)
            .animation(.default, value: model.isTokenError)
            navigationContent
                .modifier(LostOTPSheetModifier(isLostOTPSheetDisplayed: $isLostOTPSheetDisplayed,
                                               useBackupCode: { code in Task { await model.useBackupCode(code) }},
                                               lostOTPSheetViewModel: model.lostOTPSheetViewModel,
                                               context: .disable2fa))
        }
    }

    var navigationContent: some View {
        ZStack {
            switch model.state {
            case .otpInput:
                mainView
            case .inProgress:
                TwoFAProgressView(state: $model.progressState)
            case .failure:
                errorView
            case .twoFAEnforced:
                enforcementView
            }
        }
        .frame(maxWidth: .infinity)
        .onReceive(model.dismissPublisher) {
            dismiss()
        }
        .animation(.default, value: model.state)
        .animation(.default, value: model.isTokenError)
    }

    var mainView: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text(L10n.Localizable.twofaDeactivationTitle)
                .font(.custom(GTWalsheimPro.regular.name,
                              size: 28,
                              relativeTo: .title)
                    .weight(.medium))
                .foregroundColor(.ds.text.neutral.catchy)
            otpField
            Group {
                Text(L10n.Localizable.twofaDeactivationHelpTitle)
                    .foregroundColor(.ds.text.neutral.quiet) + Text(" ") +
                Text(L10n.Localizable.twofaDeactivationHelpCta)
                    .foregroundColor(.ds.text.brand.standard)
                    .underline()
            }
            .onTapGesture {
                isLostOTPSheetDisplayed = true
            }
            Spacer()
        }
        .padding(24)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(Text(L10n.Localizable.twofaStepsNavigationTitle))
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationBarButton(action: dismiss.callAsFunction, title: L10n.Localizable.cancel)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationBarButton(action: {
                    Task {
                        await model.disable(model.otpValue)
                    }
                }, label: {
                    Text(L10n.Localizable.kwNext)
                        .opacity(model.canValidate ? 1 : 0.5)
                })
                .disabled(!model.canValidate)
            }
        }
    }

    var errorView: some View {
        FeedbackView(title: L10n.Localizable.twofaDeactivationErrorTitle,
                     message: L10n.Localizable.twofaDeactivationErrorMessage,
                     primaryButton: (L10n.Localizable.twofaActivationErrorCta, {
            dismiss()
        }))
    }

    var otpField: some View {
        VStack(alignment: .leading, spacing: 4) {
            OTPField(model: OTPFieldModel(), otpValue: $model.otpValue, isError: $model.isTokenError)
            if model.isTokenError {
                Text(L10n.Localizable.twofaDeactivationIncorrectTokenErrorMessage)
                    .multilineTextAlignment(.leading)
                    .font(.callout)
                    .foregroundColor(.ds.text.danger.quiet)
            }
        }
    }

    var enforcementView: some View {
        FeedbackView(title: L10n.Localizable.twofaDisableTitle,
                     message: L10n.Localizable.twofaDisableMessage1 + "\n\n" + L10n.Localizable.twofaDisableMessage2, kind: .twoFA,
                     primaryButton: (L10n.Localizable.twofaDisableCta, { model.state = .otpInput }),
                     secondaryButton: (L10n.Localizable.cancel, { dismiss() }))
    }
}

struct TwoFADeactivationView_Previews: PreviewProvider {

    static var previews: some View {
        TwoFADeactivationView(model: .mock(state: .otpInput))
        TwoFADeactivationView(model: .mock(state: .failure))
        TwoFADeactivationView(model: .mock(state: .inProgress))
    }
}
