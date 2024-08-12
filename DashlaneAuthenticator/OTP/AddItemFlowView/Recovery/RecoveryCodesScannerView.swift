import CoreLocalization
import SwiftUI
import UIComponents
import UIDelight
import Vision

struct RecoveryCodesScannerView: View {
  @Environment(\.dismiss)
  private var dismiss

  @ObservedObject
  var model: RecoveryCodesScanViewModel

  @Binding
  var recoveryCodes: [String]

  var body: some View {
    NavigationView {
      mainView
    }
  }

  var mainView: some View {
    VStack {
      Text(L10n.Localizable.pictureRecoveryCodeTitle)
        .font(.title)
        .foregroundColor(.white)
        .padding(8)
        .multilineTextAlignment(.center)
        .frame(height: 100, alignment: .center)

      ImageCaptureView { result in
        switch result {
        case let .success(result):
          model.processImage(result)
        case .failure(let error) where error == .badInput:
          DispatchQueue.main.async {
            self.model.isCameraAlertErrorPresented = true
          }
        case .failure:
          dismiss()
        }
      }
      .alert(
        L10n.Localizable.reScanRecoveryCodesAlertTitle,
        isPresented: $model.isCameraAlertErrorPresented,
        actions: {
          Button(L10n.Localizable.authoriseCameraButtonTitle, action: openSetting)
          Button(CoreLocalization.L10n.Core.cancel, action: dismiss)
        },
        message: {
          Text(L10n.Localizable.reScanRecoveryCodesAlertMessage)
        }
      )
      .background(Color.black)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .navigationBarHidden(true)
    .background(Color.black)
    .overlay {
      if model.isProgress {
        overlayView
      }
    }
    .fullScreenCover(
      isPresented: $model.presentConfirmation,
      content: {
        RecoveryCodesConfirmationView(
          recoveryCodes: $model.recoveryCodes,
          save: {
            recoveryCodes = model.recoveryCodes
            model.save(recoveryCodes)
          }, cancel: model.cancel)
      })
  }

  var overlayView: some View {
    ZStack {
      ProgressView(L10n.Localizable.processingRecoverCodeMessage)
        .padding()
        .modifier(AlertStyle())

    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.clear)
  }

  private func openSetting() {
    UIApplication.shared.openSettings { _ in
      dismiss()
    }
  }
}
