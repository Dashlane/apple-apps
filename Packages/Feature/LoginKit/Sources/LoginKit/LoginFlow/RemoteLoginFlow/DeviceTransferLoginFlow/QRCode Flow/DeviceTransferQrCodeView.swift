import CoreImage.CIFilterBuiltins
import CoreLocalization
import CoreTypes
import DesignSystem
import Foundation
import SwiftUI
import UIComponents
import UIDelight

struct DeviceTransferQrCodeView: View {

  @StateObject
  var model: DeviceTransferQrCodeViewModel

  @State
  var progressState: ProgressionState = .inProgress("")
  @State
  var showHelp = false

  @State
  var showingConfirmation = false

  public init(model: @autoclosure @escaping () -> DeviceTransferQrCodeViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    ZStack {
      if let url = model.qrCodeUrl {
        qrcodeView(url: url)
          .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
              Button(CoreL10n.deviceToDeviceHelpCta) {
                showHelp = true
              }
              .foregroundStyle(Color.ds.text.brand.standard)
            }
          }
      } else if model.inProgress {
        LottieProgressionFeedbacksView(state: model.progressState)
      }
    }
    .animation(.default, value: model.qrCodeUrl)
    .frame(maxWidth: .infinity)
    .background(.ds.background.alternate.ignoresSafeArea())
    .loginAppearance()
    .fullScreenCover(isPresented: $model.showError) {
      FeedbackView(
        title: CoreL10n.deviceToDeviceLoginErrorTitle,
        message: CoreL10n.deviceToDeviceLoginErrorMessage,
        primaryButton: (CoreL10n.deviceToDeviceLoginErrorRetry, { model.retry() }),
        secondaryButton: (
          CoreL10n.cancel,
          {
            model.showError = false
            model.cancel()
          }
        ))
    }
  }

  @ViewBuilder
  func qrcodeView(url: String) -> some View {
    ZStack {
      VStack(alignment: .leading, spacing: 8) {
        Text(CoreL10n.deviceToDeviceQrcodeTitle)
          .foregroundStyle(Color.ds.text.neutral.catchy)
          .textStyle(.title.section.medium)
          .multilineTextAlignment(.leading)
          .padding(24)
        Spacer()
      }
      VStack(alignment: .center) {
        Spacer()
        QRCode(url: url)
          .foregroundStyle(Color.ds.text.neutral.catchy)
          .background(.ds.background.alternate)
          .frame(width: 200, height: 200)
        Spacer()
      }
      overlayButtons
    }
    .frame(maxWidth: .infinity)
    .background(.ds.background.alternate.ignoresSafeArea())
    .sheet(isPresented: $showHelp) {
      DeviceTransferLoginHelpView()
    }
    .confirmationDialog(
      "", isPresented: $showingConfirmation, presenting: model.accountRecoveryInfo
    ) { info in
      Button(CoreL10n.Mpless.D2d.Untrusted.sheetSecurityChallengeCta) {
        model.showSecurityChallenge()
      }
      Button(CoreL10n.forgotMpSheetRecoveryActionTitle) {
        model.showAccountRecovery(with: info)
      }
      Button(CoreL10n.cancel, role: .cancel) {}
    } message: { _ in
      Text(CoreL10n.Mpless.D2d.Untrusted.sheetTitle)
    }

  }

  var overlayButtons: some View {
    VStack {
      Spacer()
      if let info = model.accountRecoveryInfo, info.isEnabled {
        if info.accountType == .invisibleMasterPassword {
          Button(CoreL10n.Mpless.D2d.Untrusted.otherLoginOptionsCta) {
            showingConfirmation = true
          }
          .buttonStyle(.designSystem(.titleOnly))
          .style(mood: .brand, intensity: .quiet)
        } else {
          Button(CoreL10n.forgotMpSheetRecoveryActionTitle) {
            model.showAccountRecovery(with: info)
          }
        }
      }
    }
    .padding(24)
  }
}

struct QrCodeLoginView_Previews: PreviewProvider {
  static var previews: some View {
    DeviceTransferQrCodeView(
      model: DeviceTransferQrCodeViewModel(
        login: Login(""), stateMachine: .mock, activityReporter: .mock, completion: { _ in }))
  }
}
