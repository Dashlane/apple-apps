import UIKit
import SwiftUI
import UIDelight
import SwiftTreats
import LoginKit
import DesignSystem

struct ExportSecureArchiveView: View {

    @Environment(\.dismiss)
    private var dismiss

    @StateObject
    var viewModel: ExportSecureArchiveViewModel

    @FocusState
    var isTextFieldFocused: Bool

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
            .backgroundColorIgnoringSafeArea(Color(asset: FiberAsset.mainBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L10n.Localizable.cancel) {
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
                      dismissButton: .cancel(Text(L10n.Localizable.kwButtonOk)))
            }
            .documentPicker(export: $viewModel.exportedArchiveURL) {
                dismiss()
            }
        }
        .accentColor(Color(asset: FiberAsset.accentColor))
        .navigationViewStyle(.stack)
        .onAppear {
            isTextFieldFocused = true
        }
    }

    private var inputView: some View {
        LoginFieldBox {
            TextInput(L10n.Localizable.kwEnterYourMasterPassword,
                      text: $viewModel.passwordInput)
            .focused($isTextFieldFocused)
            .textInputIsSecure(true)
            .onSubmit {
                viewModel.export()
            }
            .style(intensity: .supershy)
        }
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
