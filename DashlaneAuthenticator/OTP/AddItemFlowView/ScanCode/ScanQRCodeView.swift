import SwiftUI
import UIDelight
import DashTypes

struct ScanQRCodeView: View {

    @Environment(\.dismiss)
    private var dismiss
    
    @State
    private var scale: CGFloat = 1

    @State
    private var isCameraAlertErrorPresented: Bool = false

    @StateObject
    var model: ScanQRCodeViewModel
    
    let showManualEntryView: () -> Void
    
    init(model: ScanQRCodeViewModel, showManualEntryView: @escaping () -> Void) {
        self._model = .init(wrappedValue: model)
        self.showManualEntryView = showManualEntryView
    }
    
    var body: some View {
       mainView
            .navigation(isActive: $model.presentError) {
                errorView
            }
    }

    var mainView: some View {
        ZStack {
            CodeScannerView(codeTypes: [.qr]) { result in
                switch result {
                case let .success(qrCode):
                    model.processQRCode(qrCode)
                case .failure(let error) where error == .badInput:
                    DispatchQueue.main.async {
                        self.isCameraAlertErrorPresented = true
                    }
                case .failure:
                    DispatchQueue.main.async {
                        self.model.presentError = true
                    }
                }
            }
            .alert(isPresented: $isCameraAlertErrorPresented, content: cameraAlert)
            .background(Color.black)
            VStack(spacing: 32) {
                Image(asset: AuthenticatorAsset.qrScanFrame)
                Text(L10n.Localizable.scanQrcodeTitle)
                    .foregroundColor(.white)
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)
            }.padding(.horizontal, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(.init(L10n.Localizable.addOtpFlowScanCodeCta))
        .hiddenNavigationTitle()
        .navigationBarStyle(.transparent(tintColor: .white, titleColor: .clear))
        .background(Color.black)
        .ignoresSafeArea(.all, edges: .all)
    }
    
    private func cameraAlert() -> Alert {
        Alert(title: Text(L10n.Localizable.enableCameraAlertTitle),
              message: Text(L10n.InfoPlist.nsCameraUsageDescription),
              primaryButton: .default(Text(L10n.Localizable.enableCameraAlertCta), action: openSetting),
              secondaryButton: .cancel({
            dismiss()
        }))
    }

    private func openSetting() {
        UIApplication.shared.openSettings() { _ in
            dismiss()
        }
    }
    
    var errorView: some View {
        FeedbackView(title: L10n.Localizable.qrcodeErrorTitle,
                     message: L10n.Localizable.qrcodeErrorSubtitle,
                     helpCTA: (L10n.Localizable.qrcodeErrorHelpTitle, UserSupportURL.troubleshooting.url),
                     primaryButton: (L10n.Localizable.errorAdd2FaTryAgain, {
            model.presentError = false
        }),
                     secondaryButton: (L10n.Localizable.qrcodeErrorCancelTitle, {
            dismiss()
            showManualEntryView()
        }))
    }
}

struct ScanQRCodeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScanQRCodeView(model: ScanQRCodeViewModel(logger: LoggerMock(), completion: {_ in}), showManualEntryView: {})
        }
    }
}
