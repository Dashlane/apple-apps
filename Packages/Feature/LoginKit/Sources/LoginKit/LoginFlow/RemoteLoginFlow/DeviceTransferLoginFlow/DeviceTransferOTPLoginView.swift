#if canImport(UIKit)
  import Foundation
  import SwiftUI
  import UIComponents
  import CoreLocalization
  import CoreSession
  import CoreNetworking
  import DashTypes
  import CoreUserTracking

  struct DeviceTransferOTPLoginView: View {

    @Environment(\.dismiss)
    var dismiss

    @StateObject
    var viewModel: DeviceTransferOTPLoginViewModel

    @FocusState
    var isTextFieldFocused: Bool

    @State
    var isLostOTPSheetDisplayed = false

    @Binding
    var progressState: ProgressionState

    public init(
      viewModel: @autoclosure @escaping () -> DeviceTransferOTPLoginViewModel,
      progressState: Binding<ProgressionState>
    ) {
      self._viewModel = .init(wrappedValue: viewModel())
      _progressState = progressState
    }

    var body: some View {
      ZStack {
        if viewModel.inProgress {
          ProgressionView(state: $progressState)
        } else {
          twoFAView
        }
      }.animation(.default, value: viewModel.showPushView)
        .padding(24)
        .navigationBarStyle(.transparent)
        .navigationBarBackButtonHidden()
        .loginAppearance()

    }

    var twoFAView: some View {
      ZStack {
        totpView
        if viewModel.showPushView {
          pushView
            .onAppear {
              Task {
                try await viewModel.sendPush()
              }
            }
        }
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          NavigationBarButton(L10n.Core.cancel) {
            viewModel.completion(.cancel)
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          NavigationBarButton(L10n.Core.next) {
            viewModel.validate()
          }.disabled(!viewModel.canValidate)
        }
      }
    }
    var pushView: some View {
      ZStack {
        ProgressionView(state: $viewModel.state)
        twoFAButton
      }
    }

    var twoFAButton: some View {
      VStack {
        Spacer()
        Button(
          L10n.Core.deviceToDevicePushFallbackCta,
          action: {
            viewModel.showPushView = false
          })
      }
    }
    @ViewBuilder
    private var totpView: some View {
      VStack(alignment: .leading, spacing: 24) {
        Text(L10n.Core.kwOtpMessage)
          .foregroundColor(.ds.text.neutral.catchy)
          .font(.custom(GTWalsheimPro.bold.name, size: 26, relativeTo: .title))
          .multilineTextAlignment(.leading)
        OTPField(otp: $viewModel.otpValue)
          .otpFieldStyle(backgroundColor: .ds.container.agnostic.neutral.standard)
          .fixedSize(horizontal: false, vertical: true)
        HStack {
          Button(
            action: {
              isLostOTPSheetDisplayed = true
            },
            label: {
              Text(L10n.Core.otpRecoveryCannotAccessCodes)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.ds.text.neutral.standard)
                .underline()
            })
          Spacer()
        }
        Spacer()
      }.background(.ds.background.alternate)
        .navigationBarStyle(.transparent)
        .modifier(
          LostOTPSheetModifier(
            isLostOTPSheetDisplayed: $isLostOTPSheetDisplayed,
            useBackupCode: { viewModel.useBackupCode($0) },
            lostOTPSheetViewModel: viewModel.lostOTPSheetViewModel))
    }

  }

  struct DeviceToDeviceOTPLoginView_Previews: PreviewProvider {
    static var previews: some View {
      DeviceTransferOTPLoginView(
        viewModel: DeviceTransferOTPLoginViewModel(
          initialState: .initialize(nil),
          login: Login("_"),
          option: .totp,
          activityReporter: .mock,
          appAPIClient: .fake,
          thirdPartyOTPLoginStateMachineFactory: .init({ _, _, _ in
            .mock(option: .totp)
          }),
          completion: { _ in }
        ),
        progressState: .constant(.inProgress(""))
      )
    }
  }

#endif
