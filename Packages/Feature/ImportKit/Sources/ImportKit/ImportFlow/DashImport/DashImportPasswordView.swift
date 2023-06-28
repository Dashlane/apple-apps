import CoreLocalization
import DesignSystem
import CoreUserTracking
import LoginKit
import SwiftUI
import UIDelight
import UIComponents

public struct DashImportPasswordView: View {
    public enum Action {
        case cancel
        case extracted
        case extractionError
    }

    @ObservedObject
    private var model: DashImportViewModel

    @FocusState
    private var isTextFieldFocused: Bool

    @State private var showWrongPasswordError = false

    @State
    private var disableUnlockButton = false

    private let action: @MainActor (Action) -> Void

    private let learnMoreURL = URL(string: "_")!

    public init(model: DashImportViewModel, action: @escaping (@MainActor (Action) -> Void)) {
        self._model = .init(wrappedValue: model)
        self.action = action
    }

    public var body: some View {
        NavigationView {
            ScrollViewIfNeeded {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                        .frame(height: 28)

                    VStack(alignment: .leading, spacing: 0) {
                        title
                        description
                    }
                    .fiberAccessibilityElement(children: .combine)

                    passwordField
                    informationBox

                    Spacer()

                    ctaButton
                }
            }
            .backgroundColorIgnoringSafeArea(.ds.background.alternate)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L10n.Core.cancel) {
                        action(.cancel)
                    }
                    .foregroundColor(.ds.text.brand.standard)
                }
            }
            .reportPageAppearance(.importBackupfileEnterPassword)
            .ignoresSafeArea(.keyboard)
        }
        .navigationViewStyle(.stack)
    }

    private var title: some View {
        Text(L10n.Core.m2WImportFromDashPasswordScreenPrimaryTitle)
            .frame(maxWidth: 400, alignment: .leading)
            .font(DashlaneFont.custom(28, .medium).font)
            .foregroundColor(.ds.text.neutral.catchy)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
    }

    private var description: some View {
        Text(L10n.Core.m2WImportFromDashPasswordScreenSecondaryTitle)
            .frame(maxWidth: 400, alignment: .leading)
            .font(.body.weight(.light))
            .foregroundColor(.ds.text.neutral.standard)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
    }

    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 8) {
            DS.PasswordField(
                L10n.Core.KWAuthentifiantIOS.password,
                placeholder: L10n.Core.m2WImportFromDashPasswordScreenFieldPlaceholder,
                text: $model.password,
                feedback: {
                    if showWrongPasswordError {
                        TextFieldTextualFeedback(L10n.Core.m2WImportFromDashPasswordScreenWrongPassword)
                            .transition(.opacity)
                    }
                }
            )
            .textFieldFeedbackAppearance(showWrongPasswordError ? .error : nil)
            .focused($isTextFieldFocused)
            .onSubmit(validate)
            .disabled(model.inProgress)
            .submitLabel(.go)
            .shakeAnimation(forNumberOfAttempts: model.attempts)
            .padding(.horizontal, 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 26)
        .onChange(of: model.showWrongPasswordError) { newValue in
            withAnimation(.easeOut(duration: 0.2)) {
                showWrongPasswordError = newValue
            }
            guard newValue else { return }
            isTextFieldFocused = true
        }

    }

    private var informationBox: some View {
        Label {
            Text(attributedDescription)
                .font(.system(.subheadline).weight(.light))
                .multilineTextAlignment(.leading)
        } icon: {
            Image(asset: Asset.infoCircleOutlined)
                .resizable()
                .renderingMode(.template)
                .frame(width: 20, height: 20)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(.ds.container.expressive.neutral.quiet.idle)
        .foregroundColor(.ds.text.neutral.standard)
        .cornerRadius(4)
        .padding(.horizontal, 24)
        .fiberAccessibilityElement(children: .combine)
        .fiberAccessibilityAction { openLearnMore() }
    }

    private var ctaButton: some View {
        RoundedButton(L10n.Core.m2WImportFromDashPasswordScreenUnlockImport, action: validate)
            .roundedButtonDisplayProgressIndicator(model.inProgress)
            .roundedButtonLayout(.fill)
            .disabled(disableUnlockButton || model.showWrongPasswordError)
            .padding(.horizontal, 16)
            .padding(.vertical, 30)
    }

    private func validate() {
        disableUnlockButton = true

        Task { @MainActor in
            do {
                try await model.validate()
                self.action(.extracted)
            } catch {
                if case DashImportViewModel.ValidationError.extractionFailed = error {
                    self.action(.extractionError)
                }
            }

            disableUnlockButton = false
        }
    }

    private func openLearnMore() {
        UIApplication.shared.open(learnMoreURL)
    }
}

private extension DashImportPasswordView {

    var attributedDescription: AttributedString {
        let learnMoreString = L10n.Core.m2WImportFromDashPasswordScreenTroubleshootingLink
        let descriptionString = L10n.Core.m2WImportFromDashPasswordScreenTroubleshooting

        return attributedString(for: descriptionString, hyperlinks: [learnMoreString: learnMoreURL])
    }

    func attributedString(for string: String, hyperlinks: [String: URL]) -> AttributedString {
        var defaultAttributes = AttributeContainer()
        defaultAttributes.font = .system(.subheadline).weight(.light)
        defaultAttributes.foregroundColor = .ds.text.neutral.standard

        var attributedString = AttributedString(string, attributes: defaultAttributes)

        for (text, url) in hyperlinks {
            guard let range = attributedString.range(of: text) else { continue }
            attributedString[range].link = url
            attributedString[range].foregroundColor = .ds.text.brand.standard
        }

        return attributedString
    }

}

struct DashImportPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(deviceRange: .some([.iPhone8, .iPhone11, .iPadPro])) {
            DashImportPasswordView(model: .mock, action: { _ in })
        }
    }
}
