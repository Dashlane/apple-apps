import SwiftUI
import Combine
import UIDelight
import DashlaneAppKit
import SwiftTreats
import LoginKit
import UIComponents
import DesignSystem

struct FastLocalSetupView<Model: FastLocalSetupViewModel>: View {

    @ObservedObject
    var model: Model

    @State
    private var shouldDisplayHowItWorksDescription: Bool = false

        @Environment(\.toast)
    var toast

    var body: some View {
        FullScreenScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(L10n.Localizable.fastLocalSetupTitle)
                    .font(DashlaneFont.custom(24, .medium).font)
                    .foregroundColor(.ds.text.neutral.standard)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 32)

                VStack(alignment: .leading, spacing: 24) {
                    if shouldDisplayHowItWorksDescription, case let .biometry(biometry) = model.mode {
                        howItWorksDescription(biometry: biometry)
                    } else {
                        settingsView
                    }
                }
                .padding(24)
                .background(Color(asset: FiberAsset.fastSetupCardBackground))
                .cornerRadius(8)

                Spacer()

                continueButton
            }
            .animation(.easeOut, value: shouldDisplayHowItWorksDescription)
            .padding(.top, 40)
            .padding(.horizontal, 24)
        }
        .reportPageAppearance(.accountCreationUnlockOption)
        .loginAppearance()
        .onReceive(model.biometryNeededPublisher, perform: showBiometryNeededToast)
        .onAppear {
            model.markDisplay()
            model.logDisplay()
        }
        .navigationBarStyle(.transparent)
    }

    @ViewBuilder
    private var settingsView: some View {
        switch model.mode {
        case .biometry(let biometry):
            biometryView(biometry: biometry)
        case .rememberMasterPassword:
            rememberMasterPasswordView
        }
    }

    private func biometryView(biometry: Biometry) -> some View {
        Group {
            Toggle(isOn: $model.isBiometricsOn, label: {
                VStack(alignment: .leading, spacing: 2) {
                    Text(biometry.displayableName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(asset: FiberAsset.dashlaneColorTealBackground))

                    Text(biometry.localizedDescription)
                        .font(.system(size: 13))
                        .foregroundColor(Color(asset: FiberAsset.fastSetupSubtitle))
                }
            })

            Toggle(isOn: $model.isMasterPasswordResetOn, label: {
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.Localizable.fastLocalSetupMasterPasswordReset)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(asset: FiberAsset.dashlaneColorTealBackground))

                    Text(L10n.Localizable.fastLocalSetupMasterPasswordResetDescription)
                        .font(.system(size: 13))
                        .foregroundColor(Color(asset: FiberAsset.fastSetupSubtitle))
                }
            }).hidden(!model.shouldShowMasterPasswordReset)

            Button(action: showHowItWorksDescription, label: {
                howItWorksButtonTitle
            })
        }
    }

    private var rememberMasterPasswordView: some View {
        Toggle(isOn: $model.isRememberMasterPasswordOn, label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.Localizable.fastLocalSetupRememberMPTitle)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(asset: FiberAsset.dashlaneColorTealBackground))

                Text(L10n.Localizable.fastLocalSetupRememberMPDescription)
                    .font(.system(size: 13))
                    .foregroundColor(Color(asset: FiberAsset.fastSetupSubtitle))
            }
        })

    }

    private var howItWorksButtonTitle: some View {
        let text = Text(L10n.Localizable.fastLocalSetupHowItWorksTitle)
            .font(.system(size: 16, weight: .semibold))
        let arrow = Text("→")
            .font(.system(size: 16, weight: .regular))
        let combinedTitle = text + Text(" ") + arrow

        return combinedTitle.foregroundColor(Color(asset: FiberAsset.midGreen))
    }

    private var backButtonTitle: some View {
        let arrow = Text("←")
            .font(.system(size: 16, weight: .regular))
        let text = Text(L10n.Localizable.fastLocalSetupHowItWorksBack)
            .font(.system(size: 16, weight: .semibold))
        let combinedTitle = arrow + Text(" ") + text

        return combinedTitle.foregroundColor(Color(asset: FiberAsset.midGreen))
    }

    private func howItWorksDescription(biometry: Biometry) -> some View {
        Group {
            Button(action: hideHowItWorksDescription, label: {
                backButtonTitle
            })

            Group {
                Text(L10n.Localizable.fastLocalSetupHowItWorksResetAvailableDescription(biometry.displayableName))
                Text(L10n.Localizable.fastLocalSetupHowItWorksNote(biometry.displayableName))
            }
            .foregroundColor(Color(asset: FiberAsset.fastSetupInfo))
        }
    }

    private var continueButton: some View {
        RoundedButton(L10n.Localizable.fastLocalSetupContinue,
                      action: model.next)
        .roundedButtonLayout(.fill)
        .padding(.bottom, 35)
    }

    func showHowItWorksDescription() {
        shouldDisplayHowItWorksDescription = true
    }

    func hideHowItWorksDescription() {
        shouldDisplayHowItWorksDescription = false
    }

    private func showBiometryNeededToast() {
        guard let biometry = model.biometry else { return }
        toast(L10n.Localizable.fastLocalSetupBiometryRequiredForMasterPasswordReset(biometry.displayableName), image: .ds.feedback.info.outlined)
    }
}

private extension Biometry {
    var localizedDescription: String {
        switch self {
        case .touchId:
            return L10n.Localizable.fastLocalSetupTouchIDDescription
        case .faceId:
            return L10n.Localizable.fastLocalSetupFaceIDDescription
        }
    }
}

struct FastLocalSetupView_Previews: PreviewProvider {

    class FakeModel: FastLocalSetupViewModel {
        var mode: FastLocalSetupMode
        var isBiometricsOn: Bool = true
        var isMasterPasswordResetOn: Bool = true
        var shouldShowMasterPasswordReset: Bool = true
        var shouldShowBackButton: Bool = true
        var biometryNeededPublisher = PassthroughSubject<Void, Never>()
        var biometry: Biometry? = .faceId
        var isRememberMasterPasswordOn: Bool = true

        func next() {}
        func back() {}
        func markDisplay() {}
        func logDisplay() {}

        init(mode: FastLocalSetupMode = .biometry(.faceId)) {
            self.mode = mode
        }
    }

    static var previews: some View {
        MultiContextPreview(deviceRange: .some([.iPhoneSE, .iPhone11, .iPadPro])) {
            FastLocalSetupView(model: FakeModel())
            FastLocalSetupView(model: FakeModel(mode: .rememberMasterPassword))
        }
    }
}
