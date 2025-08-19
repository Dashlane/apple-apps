import CoreLocalization
import Foundation
import SwiftUI
import UIDelight

@available(visionOS, unavailable)
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
          CoreL10n.kwOtpSecretUpdate,
          isPresented: $isCameraAlertErrorPresented,
          actions: {
            Button(CoreL10n.kwAuthoriseCameraAccess) {
              openSetting()
            }
            Button(CoreL10n.cancel) {
              self.dismiss()
            }
          },
          message: {
            Text(CoreL10n.kwRequiresCameraAccess)
          }
        )
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.black, ignoresSafeAreaEdges: .all)
        VStack(spacing: 32) {
          Image(.qrScanFrame)
          Text(L10n.Localizable.addNewDeviceScanCta)
            .foregroundStyle(Color.ds.text.inverse.catchy)
            .font(.title2.weight(.semibold))
            .multilineTextAlignment(.center)
        }.padding(.horizontal, 48)
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(CoreL10n.cancel) {
            dismiss()
          }
          .foregroundStyle(Color.ds.text.inverse.standard)
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

@available(visionOS, unavailable)
#Preview {
  ScanQrCodeView { _ in }
}
