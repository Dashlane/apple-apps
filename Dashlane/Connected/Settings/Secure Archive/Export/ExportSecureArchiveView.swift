import CoreLocalization
import CorePasswords
import DesignSystem
import LoginKit
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight
import UIKit

struct ExportSecureArchiveView: View {
  @Environment(\.dismiss) private var dismiss

  @StateObject private var viewModel: ExportSecureArchiveViewModel
  @FocusState private var isTextFieldFocused: Bool

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
          ProgressionView(state: $progressState)
        }
      }
      .animation(.default, value: viewModel.inProgress)
      .backgroundColorIgnoringSafeArea(.ds.background.alternate)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(CoreLocalization.L10n.Core.cancel) {
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
    .accentColor(.ds.text.brand.standard)
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
      .fieldAppearance(.standalone)
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

struct ExportSecureArchiveView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      ExportSecureArchiveView(viewModel: .mock)
    }
  }
}

extension TextInputPasswordStrengthFeedback.Strength {
  fileprivate init?(strength: PasswordStrength) {
    self.init(rawValue: strength.rawValue + 1)
  }
}
