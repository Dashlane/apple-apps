import CoreLocalization
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight
import UserTrackingFoundation

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
      ScrollView {
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
      .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(CoreL10n.cancel) {
            action(.cancel)
          }
          .foregroundStyle(Color.ds.text.brand.standard)
        }
      }
      .reportPageAppearance(.importBackupfileEnterPassword)
      .ignoresSafeArea(.keyboard)
    }
    .navigationViewStyle(.stack)
  }

  private var title: some View {
    Text(CoreL10n.m2WImportFromDashPasswordScreenPrimaryTitle)
      .frame(maxWidth: 400, alignment: .leading)
      .textStyle(.title.section.large)
      .foregroundStyle(Color.ds.text.neutral.catchy)
      .multilineTextAlignment(.leading)
      .padding(.horizontal, 16)
      .padding(.bottom, 8)
  }

  private var description: some View {
    Text(CoreL10n.m2WImportFromDashPasswordScreenSecondaryTitle)
      .frame(maxWidth: 400, alignment: .leading)
      .font(.body.weight(.light))
      .foregroundStyle(Color.ds.text.neutral.standard)
      .multilineTextAlignment(.leading)
      .padding(.horizontal, 16)
      .padding(.bottom, 24)
  }

  private var passwordField: some View {
    VStack(alignment: .leading, spacing: 8) {
      DS.PasswordField(
        CoreL10n.KWAuthentifiantIOS.password,
        placeholder: CoreL10n.m2WImportFromDashPasswordScreenFieldPlaceholder,
        text: $model.password,
        feedback: {
          if showWrongPasswordError {
            FieldTextualFeedback(CoreL10n.m2WImportFromDashPasswordScreenWrongPassword)
              .transition(.opacity)
          }
        }
      )
      .style(showWrongPasswordError ? .error : nil)
      .focused($isTextFieldFocused)
      .onSubmit(validate)
      .disabled(model.inProgress)
      .submitLabel(.go)
      .shakeAnimation(forNumberOfAttempts: model.attempts)
      .padding(.horizontal, 8)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 26)
    .onChange(of: model.showWrongPasswordError) { _, newValue in
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
      Image.ds.feedback.info.outlined
        .resizable()
        .renderingMode(.template)
        .frame(width: 20, height: 20)
    }
    .frame(maxWidth: .infinity)
    .padding(16)
    .background(.ds.container.expressive.neutral.quiet.idle)
    .foregroundStyle(Color.ds.text.neutral.standard)
    .cornerRadius(4)
    .padding(.horizontal, 24)
    .fiberAccessibilityElement(children: .combine)
    .fiberAccessibilityAction { openLearnMore() }
  }

  private var ctaButton: some View {
    Button(CoreL10n.m2WImportFromDashPasswordScreenUnlockImport, action: validate)
      .buttonDisplayProgressIndicator(model.inProgress)
      .buttonStyle(.designSystem(.titleOnly))
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

extension DashImportPasswordView {

  fileprivate var attributedDescription: AttributedString {
    let learnMoreString = CoreL10n.m2WImportFromDashPasswordScreenTroubleshootingLink
    let descriptionString = CoreL10n.m2WImportFromDashPasswordScreenTroubleshooting

    return attributedString(for: descriptionString, hyperlinks: [learnMoreString: learnMoreURL])
  }

  fileprivate func attributedString(for string: String, hyperlinks: [String: URL])
    -> AttributedString
  {
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

#Preview {
  DashImportPasswordView(model: .mock) { _ in }
}
