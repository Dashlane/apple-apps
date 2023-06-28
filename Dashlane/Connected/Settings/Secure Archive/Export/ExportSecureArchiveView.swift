import UIKit
import SwiftUI
import UIDelight
import SwiftTreats
import LoginKit
import DesignSystem
import CoreLocalization

struct ExportSecureArchiveView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: ExportSecureArchiveViewModel
    @FocusState private var isTextFieldFocused: Bool

    init(viewModel: @autoclosure @escaping () -> ExportSecureArchiveViewModel) {
        _viewModel = .init(wrappedValue: viewModel())
    }

    var body: some View {
        NavigationView {
            Group {
                switch viewModel.state {
                case .main:
                    inputView
                case .inProgress:
                    progressView
                }
            }
            .backgroundColorIgnoringSafeArea(.ds.background.default)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(CoreLocalization.L10n.Core.cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Export") {
                        viewModel.export()
                    }
                    .activitySheet($viewModel.activityItem) { _, _, _, _ in
                        dismiss()
                    }
                }
            }
            .alert(isPresented: $viewModel.displayInputError) {
                Alert(title: Text(L10n.Localizable.exporterUnlockAlertWrongMpTitle),
                      message: Text(L10n.Localizable.exporterUnlockAlertWrongMpMessage),
                      dismissButton: .cancel(Text(CoreLocalization.L10n.Core.kwButtonOk)))
            }
            .documentPicker(export: $viewModel.exportedArchiveURL) {
                dismiss()
            }
        }
        .accentColor(.ds.text.brand.standard)
        .navigationViewStyle(.stack)
        .onAppear {
            isTextFieldFocused = true
        }
    }

    private var inputView: some View {
        DS.PasswordField(
            CoreLocalization.L10n.Core.kwEnterYourMasterPassword,
            text: $viewModel.passwordInput
        )
        .focused($isTextFieldFocused)
        .onSubmit(viewModel.export)
        .textFieldAppearance(.standalone)
        .padding(.horizontal)
    }

    private var progressView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            Text("Exporting Secure Archive…")
        }
    }
}

struct ExportSecureArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            ExportSecureArchiveView(viewModel: .mock)
        }
    }
}
