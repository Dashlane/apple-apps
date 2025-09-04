import CoreLocalization
import CorePasswords
import DesignSystem
import LoginKit
import SwiftUI

struct ExportSecureArchiveView: View {
  @Environment(\.dismiss)
  private var dismiss

  @StateObject
  private var viewModel: ExportSecureArchiveViewModel

  @FocusState
  private var isTextFieldFocused: Bool

  init(viewModel: @autoclosure @escaping () -> ExportSecureArchiveViewModel) {
    _viewModel = .init(wrappedValue: viewModel())
  }

  @State
  var progressState: ProgressionState = .inProgress(L10n.Localizable.dashExportProgressLabel)

  var body: some View {
    NavigationView {
      ZStack {
        mainView
        if viewModel.inProgress {
          LottieProgressionFeedbacksView(state: progressState)
        }
      }
      .animation(.default, value: viewModel.inProgress)
      .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(CoreL10n.cancel) {
            dismiss()
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(L10n.Localizable.dashExportCta) {
            viewModel.export()
          }
          .disabled(viewModel.inProgress)
          .activitySheet($viewModel.activityItem) { _, _, _, _ in
            dismiss()
          }
        }
      }
    }
    .tint(.ds.text.brand.standard)
    .navigationViewStyle(.stack)
    .onAppear {
      isTextFieldFocused = true
    }
  }

  var mainView: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(L10n.Localizable.dashExportTitle)
        .multilineTextAlignment(.leading)
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
        .textStyle(.specialty.brand.small)
        .foregroundStyle(Color.ds.text.neutral.catchy)
      DS.PasswordField(
        L10n.Localizable.dashExportPlaceholder,
        placeholder: "",
        text: $viewModel.passwordInput,
        feedback: {
          if let passwordStrength = viewModel.passwordStrength.flatMap(
            TextInputPasswordStrengthFeedback.Strength.init(strength:))
          {
            TextInputPasswordStrengthFeedback(strength: passwordStrength)
              .transition(.opacity)
          }
        }
      )
      .focused($isTextFieldFocused)
      .onSubmit {
        viewModel.export()
      }
      .submitLabel(.go)
    }
    .frame(maxHeight: .infinity, alignment: .top)
    .padding(.all, 24)

  }
}

extension TextInputPasswordStrengthFeedback.Strength {
  fileprivate init?(strength: PasswordStrength) {
    self.init(rawValue: strength.rawValue + 1)
  }
}

#Preview {
  ExportSecureArchiveView(viewModel: .mock)
}
