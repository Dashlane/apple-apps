import CoreLocalization
import CoreSession
import CoreTypes
import DashlaneAPI
import DesignSystem
import Foundation
import LoginKit
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight
import UserTrackingFoundation

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
        LottieProgressionFeedbacksView(state: model.progressState)
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
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
      .navigationTitle(L10n.Localizable.Mpless.D2d.trustedNavigationTitle)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(CoreL10n.cancel) {
            dismiss()
          }
          .foregroundStyle(Color.ds.text.brand.standard)
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
          .foregroundStyle(Color.ds.text.neutral.catchy)
          .textStyle(.title.section.large)

        InstructionsCardView(cardContent: [
          model.message1,
          model.message2,
          model.message3,
        ])
        Spacer()
      }
      .padding(24)
    }
  }

  var overlayView: some View {
    VStack(spacing: 8) {
      Spacer()
      if !Device.is(.mac) {
        Button(L10n.Localizable.addNewDeviceScanCta) {
          model.showScanner = true
        }
        .style(mood: .brand, intensity: .catchy)
      }

      if model.isPasswordlessAccount {
        Button(L10n.Localizable.Mpless.D2d.Universal.refreshCta) {
          model.checkPendingRequest()
        }
        .style(mood: .brand, intensity: !Device.is(.mac) ? .quiet : .catchy)
      }
    }
    .buttonStyle(.designSystem(.titleOnly))
    .padding(24)
  }

  var scanView: some View {
    #if os(visionOS)
      Text("Not Supported on VisionOS")
    #else
      ScanQrCodeView { qrcode in
        model.didScanQRCode(qrcode)
      }
      .reportPageAppearance(.settingsAddNewDeviceScanQrCode)
    #endif
  }

  @ViewBuilder
  func errorView(for error: AddNewDeviceViewModel.Error) -> some View {
    switch error {
    case .generic:
      FeedbackView(
        title: CoreL10n.deviceToDeviceLoginErrorTitle,
        message: CoreL10n.deviceToDeviceLoginErrorMessage,
        primaryButton: (CoreL10n.deviceToDeviceLoginErrorRetry, { model.state = .intro }),
        secondaryButton: (
          CoreL10n.cancel,
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
