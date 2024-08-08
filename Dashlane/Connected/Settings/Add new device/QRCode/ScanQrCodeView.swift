import CoreLocalization
import Foundation
import SwiftUI
import UIDelight

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
        .alert(
          CoreLocalization.L10n.Core.kwOtpSecretUpdate,
          isPresented: $isCameraAlertErrorPresented,
          actions: {
            Button(CoreLocalization.L10n.Core.kwAuthoriseCameraAccess) {
              openSetting()
            }
            Button(CoreLocalization.L10n.Core.cancel) {
              self.dismiss()
            }
          },
          message: {
            Text(CoreLocalization.L10n.Core.kwRequiresCameraAccess)
          }
        )
        .backgroundColorIgnoringSafeArea(.black)
        VStack(spacing: 32) {
          Image(asset: FiberAsset.qrScanFrame)
          Text(L10n.Localizable.addNewDeviceScanCta)
            .foregroundColor(.ds.text.inverse.catchy)
            .font(.title2.weight(.semibold))
            .multilineTextAlignment(.center)
        }.padding(.horizontal, 48)
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(CoreLocalization.L10n.Core.cancel) {
            dismiss()
          }
          .foregroundColor(.ds.text.inverse.standard)
        }
      }
      .toolbarColorScheme(.dark, for: .navigationBar)
    }
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
    ScanQrCodeView { _ in }
  }
}
