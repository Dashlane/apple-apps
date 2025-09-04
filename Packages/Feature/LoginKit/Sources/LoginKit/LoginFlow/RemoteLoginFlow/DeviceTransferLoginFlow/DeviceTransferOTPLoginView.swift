import CoreLocalization
import CoreNetworking
import CoreSession
import CoreTypes
import DesignSystemExtra
import Foundation
import SwiftUI
import UserTrackingFoundation

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
        LottieProgressionFeedbacksView(state: progressState)
      } else {
        twoFAView
      }
    }.animation(.default, value: viewModel.showPushView)
      .padding(24)
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
              await viewModel.sendPush()
            }
          }
      }
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button(CoreL10n.cancel) {
          viewModel.completion(.cancel)
        }
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(CoreL10n.next) {
          viewModel.validate()
        }.disabled(!viewModel.canValidate)
      }
    }
  }
  var pushView: some View {
    ZStack {
      LottieProgressionFeedbacksView(state: viewModel.state)
      twoFAButton
    }
  }

  var twoFAButton: some View {
    VStack {
      Spacer()
      Button(
        CoreL10n.deviceToDevicePushFallbackCta,
        action: {
          viewModel.showPushView = false
        })
    }
  }
  @ViewBuilder
  private var totpView: some View {
    VStack(alignment: .leading, spacing: 24) {
      Text(CoreL10n.kwOtpMessage)
        .foregroundStyle(Color.ds.text.neutral.catchy)
        .textStyle(.title.section.medium)
        .multilineTextAlignment(.leading)
      OTPInputField(otp: $viewModel.otpValue)
        .fixedSize(horizontal: false, vertical: true)
      HStack {
        Button(
          action: {
            isLostOTPSheetDisplayed = true
          },
          label: {
            Text(CoreL10n.otpRecoveryCannotAccessCodes)
              .font(.subheadline.weight(.medium))
              .foregroundStyle(Color.ds.text.neutral.standard)
              .underline()
          })
        Spacer()
      }
      Spacer()
    }
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
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
        stateMachine: .mock(option: .totp),
        login: Login("_"),
        option: .totp,
        activityReporter: .mock,
        appAPIClient: .fake,
        completion: { _ in }
      ),
      progressState: .constant(.inProgress(""))
    )
  }
}
