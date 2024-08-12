import CoreImage.CIFilterBuiltins
import CoreLocalization
import DashTypes
import DesignSystem
import Foundation
import SwiftUI
import UIComponents
import UIDelight

#if canImport(UIKit)
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
                Button(L10n.Core.deviceToDeviceHelpCta) {
                  showHelp = true
                }
                .foregroundColor(.ds.text.brand.standard)
              }
            }
        } else if model.inProgress {
          ProgressionView(state: $model.progressState)
        }
      }
      .animation(.default, value: model.qrCodeUrl)
      .frame(maxWidth: .infinity)
      .background(.ds.background.alternate.ignoresSafeArea())
      .navigationBarStyle(.transparent)
      .loginAppearance()
      .fullScreenCover(isPresented: $model.showError) {
        FeedbackView(
          title: L10n.Core.deviceToDeviceLoginErrorTitle,
          message: L10n.Core.deviceToDeviceLoginErrorMessage,
          primaryButton: (L10n.Core.deviceToDeviceLoginErrorRetry, { model.retry() }),
          secondaryButton: (
            CoreLocalization.L10n.Core.cancel,
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
          Text(L10n.Core.deviceToDeviceQrcodeTitle)
            .foregroundColor(.ds.text.neutral.catchy)
            .font(.custom(GTWalsheimPro.bold.name, size: 26, relativeTo: .title).weight(.medium))
            .multilineTextAlignment(.leading)
            .padding(24)
          Spacer()
        }
        VStack(alignment: .center) {
          Spacer()
          QRCode(url: url)
            .foregroundColor(.ds.text.neutral.catchy)
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
        Button(L10n.Core.Mpless.D2d.Untrusted.sheetSecurityChallengeCta) {
          model.showSecurityChallenge()
        }
        Button(L10n.Core.forgotMpSheetRecoveryActionTitle) {
          model.showAccountRecovery(with: info)
        }
        Button(L10n.Core.cancel, role: .cancel) {}
      } message: { _ in
        Text(L10n.Core.Mpless.D2d.Untrusted.sheetTitle)
      }

    }

    var overlayButtons: some View {
      VStack {
        Spacer()
        if let info = model.accountRecoveryInfo, info.isEnabled {
          if info.accountType == .invisibleMasterPassword {
            Button(L10n.Core.Mpless.D2d.Untrusted.otherLoginOptionsCta) {
              showingConfirmation = true
            }
            .buttonStyle(.designSystem(.titleOnly))
            .style(mood: .brand, intensity: .quiet)
          } else {
            Button(L10n.Core.forgotMpSheetRecoveryActionTitle) {
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
          login: Login(""), state: .waitingForQRCodeScan, activityReporter: .mock,
          deviceTransferQRCodeStateMachineFactory: .init({ _, _, _ in
            .mock
          }), completion: { _ in }))
    }
  }
#endif
