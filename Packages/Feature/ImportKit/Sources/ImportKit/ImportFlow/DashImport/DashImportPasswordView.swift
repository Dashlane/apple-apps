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

    @State
    private var disableUnlockButton = false

    private let action: (Action) -> Void

    private let learnMoreURL = URL(string: "_")!

    public init(model: DashImportViewModel, action: @escaping ((Action) -> Void)) {
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
            TextInput(L10n.Core.m2WImportFromDashPasswordScreenFieldPlaceholder, text: $model.password)
                .focused($isTextFieldFocused)
                .textInputIsSecure(true)
                .onSubmit(validate)
                .disabled(model.inProgress)
                .submitLabel(.go)
                .shakeAnimation(forNumberOfAttempts: model.attempts)
                .padding(.horizontal, 8)

            if model.showWrongPasswordError {
                Text(L10n.Core.m2WImportFromDashPasswordScreenWrongPassword)
                    .font(.footnote)
                    .foregroundColor(.ds.text.danger.standard)
                    .padding(.horizontal, 12)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 26)
        .onChange(of: model.showWrongPasswordError) { newValue in
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
        .disabled(disableUnlockButton && !model.showWrongPasswordError)
        .padding(.horizontal, 16)
        .padding(.vertical, 30)
    }

    private func validate() {
        disableUnlockButton = true

        model.validate { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.action(.extracted)
                case .failure:
                    self.action(.extractionError)
                }
            }
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
