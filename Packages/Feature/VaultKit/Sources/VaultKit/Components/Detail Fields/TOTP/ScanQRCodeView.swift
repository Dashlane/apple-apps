import AVFoundation
import CoreLocalization
import SwiftUI
import TOTPGenerator
import UIComponents
import UIDelight
import UserTrackingFoundation

@available(visionOS, unavailable)
public struct ScanQRCodeView: View {

  enum ScannerAlert: String, Identifiable {
    var id: String {
      return rawValue
    }
    case camera
    case dashlaneCode
  }

  @Environment(\.dismiss)
  private var dismiss

  @State
  private var scale: CGFloat = 1

  @State
  private var alert: ScannerAlert?

  var resultHandler: (Result<OTPConfiguration, Error>) -> Void

  public init(resultHandler: @escaping (Result<OTPConfiguration, Error>) -> Void) {
    self.resultHandler = resultHandler
  }

  public var body: some View {
    VStack {
      Text(CoreL10n._2faSetupCta)
        .font(.title2)
        .lineLimit(2)
        .minimumScaleFactor(0.6)
        .padding(8)
        .frame(height: 70, alignment: .center)

      CodeScannerView(codeTypes: [.qr]) { result in
        switch result {
        case let .success(qrCode):
          do {
            let info = try OTPConfiguration(otpString: qrCode, supportDashlane2FA: false)
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
              self.resultHandler(.success(info))
            }
          } catch {
            if case OTPUrlParserError.dashlaneSecretDetected = error {
              alert = .dashlaneCode
            } else {
              self.resultHandler(.failure(error))
            }
          }
        case .failure:
          DispatchQueue.main.async {
            alert = .camera
          }
        }
      }
      .alert(item: $alert) { item in
        switch item {
        case .camera:
          return cameraAlert()
        case .dashlaneCode:
          return dashlaneAlert()
        }
      }
      .background(Color.black)
      .overlay(overlay)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .reportPageAppearance(.toolsAuthenticatorSetupQrCode)
    .colorScheme(.dark)
  }

  private var overlay: some View {
    Group {
      if alert == nil {
        CameraOverlayShape()
          .stroke(Color.red, lineWidth: 4)
          .opacity(0.9)
          .scaleEffect(scale)
          .animation(Animation.easeInOut(duration: 1).repeatForever(), value: scale)
          .onAppear {
            scale = 1.1
          }
      }
    }
  }

  private func cameraAlert() -> Alert {
    Alert(
      title: Text(CoreL10n.kwOtpSecretUpdate),
      message: Text(CoreL10n.kwRequiresCameraAccess),
      primaryButton: .default(Text(CoreL10n.kwAuthoriseCameraAccess), action: openSetting),
      secondaryButton: .cancel({
        self.dismiss()
      }))
  }

  private func dashlaneAlert() -> Alert {
    Alert(
      title: Text(""),
      message: Text(CoreL10n.kwOtpDashlaneSecretRead),
      dismissButton: .cancel(Text(CoreL10n.kwButtonOk)))
  }

  private func openSetting() {
    #if !EXTENSION
      UIApplication.shared.openSettings { _ in
        self.dismiss()
      }
    #endif
  }
}

private struct CameraOverlayShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()

    let diff = rect.width - rect.height
    let offset = abs(diff) / 2.0
    let size = floor(diff < 0 ? rect.width : rect.height)
    let left = floor(size * 0.12 + (diff < 0 ? 0 : offset))
    let top = floor(size * 0.12 + (diff < 0 ? offset : 0))
    let right = floor(size * 0.88 + (diff < 0 ? 0 : offset))
    let bottom = floor(size * 0.88 + (diff < 0 ? offset : 0))
    let lineLength = floor(size * 0.15)
    let halfLineWidth: CGFloat = 2.0

    path.addLines([
      CGPoint(x: left + lineLength, y: top),
      CGPoint(x: left - halfLineWidth, y: top),
      CGPoint(x: left, y: top),
      CGPoint(x: left, y: top + lineLength),
    ])

    path.addLines([
      CGPoint(x: left, y: bottom - lineLength),
      CGPoint(x: left, y: bottom + halfLineWidth),
      CGPoint(x: left, y: bottom),
      CGPoint(x: left + lineLength, y: bottom),
    ])

    path.addLines([
      CGPoint(x: right - lineLength, y: top),
      CGPoint(x: right - halfLineWidth, y: top),
      CGPoint(x: right, y: top),
      CGPoint(x: right, y: top + lineLength),
    ])

    path.addLines([
      CGPoint(x: right, y: bottom - lineLength),
      CGPoint(x: right, y: bottom + halfLineWidth),
      CGPoint(x: right, y: bottom),
      CGPoint(x: right - lineLength, y: bottom),
    ])

    return path
  }
}

@available(visionOS, unavailable)
#Preview {
  ScanQRCodeView { _ in }
}
