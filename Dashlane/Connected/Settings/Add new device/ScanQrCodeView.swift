import Foundation
import SwiftUI
import UIDelight
import CoreLocalization

struct ScanQrCodeView: View {

    @Environment(\.dismiss)
    var dismiss

    let completion: (String) -> Void

    @State
    var isCameraAlertErrorPresented = false

    var body: some View {
        NavigationView {
            ZStack {
                CodeScannerView(codeTypes: [.qr]) { result in
                    switch result {
                    case let .success(qrCode):
                        dismiss()
                        completion(qrCode)
                    case .failure:
                        DispatchQueue.main.async {
                            self.isCameraAlertErrorPresented = true
                        }
                    }
                }
                .alert(isPresented: $isCameraAlertErrorPresented, content: cameraAlert)
                .backgroundColorIgnoringSafeArea(.black)
                VStack(spacing: 32) {
                    Image(asset: FiberAsset.qrScanFrame)
                    Text(L10n.Localizable.addNewDeviceScanCta)
                        .foregroundColor(.ds.text.inverse.catchy)
                        .font(.title2.weight(.semibold))
                        .multilineTextAlignment(.center)
                }.padding(.horizontal, 48)
            }
            .navigationBarStyle(.transparent)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(CoreLocalization.L10n.Core.cancel) {
                        dismiss()
                    }
                    .foregroundColor(.ds.text.inverse.standard)
                }
            }
        }
    }

    private func cameraAlert() -> Alert {
        Alert(title: Text(CoreLocalization.L10n.Core.kwOtpSecretUpdate),
              message: Text(CoreLocalization.L10n.Core.kwRequiresCameraAccess),
              primaryButton: .default(Text(CoreLocalization.L10n.Core.kwAuthoriseCameraAccess), action: openSetting),
              secondaryButton: .cancel({
                self.dismiss()
              }))
    }

    private func openSetting() {
        #if !EXTENSION
        UIApplication.shared.openSettings { _ in
            self.dismiss()
        }
        #endif
    }

}

struct ScanQrCodeView_Previews: PreviewProvider {
    static var previews: some View {
        ScanQrCodeView {_ in }
    }
}
