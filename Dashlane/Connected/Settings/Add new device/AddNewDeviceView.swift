import CoreLocalization
import CoreSession
import CoreUserTracking
import DashTypes
import DashlaneAPI
import DesignSystem
import Foundation
import LoginKit
import SwiftUI
import UIComponents
import UIDelight

struct AddNewDeviceView: View {

  @StateObject
  var model: AddNewDeviceViewModel

  @Environment(\.dismiss)
  var dismiss

  init(model: @autoclosure @escaping () -> AddNewDeviceViewModel) {
    _model = .init(wrappedValue: model())
  }

  var body: some View {
    ZStack {
      switch model.state {
      case .loading:
        ProgressionView(state: $model.progressState)
      case let .pendingTransfer(transfer):
        SecurityChallengeFlow(model: model.makeSecurityChallengeFlowModel(for: transfer))
      case .intro:
        navigationView
      case let .error(error):
        errorView(for: error)
      }
    }
    .animation(.default, value: model.state)
    .onReceive(model.dismissPublisher) {
      dismiss()
    }
    .reportPageAppearance(.settingsAddNewDevice)
  }

  var navigationView: some View {
    NavigationView {
      ZStack {
        mainView
        overlayView
      }
      .navigationTitle(L10n.Localizable.Mpless.D2d.trustedNavigationTitle)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(CoreLocalization.L10n.Core.cancel) {
            dismiss()
          }
          .foregroundColor(.ds.text.brand.standard)
        }
      }
      .animation(.default, value: model.showScanner)
      .sheet(isPresented: $model.showScanner) {
        scanView
      }
    }
  }

  var mainView: some View {
    ScrollView {
      VStack(alignment: .leading) {
        Text(model.title)
          .foregroundColor(.ds.text.neutral.catchy)
          .font(.custom(GTWalsheimPro.bold.name, size: 26, relativeTo: .title).weight(.medium))
        InstructionsCardView(cardContent: [
          model.message1,
          model.message2,
          model.message3,
        ])
        Spacer()
      }
      .padding(24)
    }
    .backgroundColorIgnoringSafeArea(.ds.background.alternate)
  }

  var overlayView: some View {
    VStack(spacing: 8) {
      Spacer()
      Button(L10n.Localizable.addNewDeviceScanCta) {
        model.showScanner = true
      }
      .style(mood: .brand, intensity: .catchy)

      if model.isPasswordlessAccount {
        Button(L10n.Localizable.Mpless.D2d.Universal.refreshCta) {
          model.checkPendingRequest()
        }
        .style(mood: .brand, intensity: .quiet)
      }
    }
    .buttonStyle(.designSystem(.titleOnly))
    .padding(24)
  }

  var scanView: some View {
    ScanQrCodeView { qrcode in
      model.didScanQRCode(qrcode)
    }
    .reportPageAppearance(.settingsAddNewDeviceScanQrCode)
  }

  @ViewBuilder
  func errorView(for error: AddNewDeviceViewModel.Error) -> some View {
    switch error {
    case .generic:
      FeedbackView(
        title: CoreLocalization.L10n.Core.deviceToDeviceLoginErrorTitle,
        message: CoreLocalization.L10n.Core.deviceToDeviceLoginErrorMessage,
        primaryButton: (
          CoreLocalization.L10n.Core.deviceToDeviceLoginErrorRetry, { model.state = .intro }
        ),
        secondaryButton: (
          CoreLocalization.L10n.Core.cancel,
          {
            dismiss()
          }
        ))
    case .timeout:
      FeedbackView(
        title: L10n.Localizable.Mpless.D2d.Trusted.timeoutErrorTitle,
        message: L10n.Localizable.Mpless.D2d.Trusted.timeoutErrorMessage,
        primaryButton: (
          L10n.Localizable.Mpless.D2d.Trusted.timeoutErrorCta,
          {
            dismiss()
          }
        ))
    }
  }
}

struct AddNewDeviceView_Previews: PreviewProvider {
  static var previews: some View {
    AddNewDeviceView(model: .mock(accountType: AccountType.masterPassword))
    AddNewDeviceView(model: .mock(accountType: .invisibleMasterPassword))
  }
}
