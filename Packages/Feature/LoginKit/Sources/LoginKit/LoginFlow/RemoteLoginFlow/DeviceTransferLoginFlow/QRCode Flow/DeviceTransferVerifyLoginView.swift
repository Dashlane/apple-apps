import CoreLocalization
import CoreSession
import CoreTypes
import DashlaneAPI
import DesignSystem
import Foundation
import SwiftUI
import UIComponents

struct DeviceTransferVerifyLoginView: View {

  public enum Completion {
    case confirm
    case cancel
  }

  let login: Login

  @State
  var isLoading = false

  @State
  var showError = false

  @Binding
  var progressState: ProgressionState

  let completion: (Completion) -> Void

  @Environment(\.dismiss)
  var dismiss

  var body: some View {
    ZStack {
      if isLoading {
        LottieProgressionFeedbacksView(state: progressState)
      } else {
        loginView
      }
    }
    .frame(maxWidth: .infinity)
    .padding(24)
    .loginAppearance()
    .animation(.default, value: isLoading)
    .navigationBarBackButtonHidden()
    .navigationTitle(CoreL10n.deviceToDeviceNavigationTitle)
    .navigationBarTitleDisplayMode(.inline)
  }

  @ViewBuilder
  var loginView: some View {
    VStack(alignment: .leading) {
      topView

      Spacer()

      bottonView
    }
    .frame(maxWidth: .infinity)
  }

  @ViewBuilder
  var topView: some View {
    VStack(alignment: .leading) {
      Text(CoreL10n.deviceToDeviceVerifyLoginTitle)
        .foregroundStyle(Color.ds.text.neutral.catchy)
        .textStyle(.title.section.large)
        .multilineTextAlignment(.leading)
      Text(CoreL10n.deviceToDeviceVerifyLoginMessage)
        .foregroundStyle(Color.ds.text.neutral.standard)
        .padding(.top, 4)
        .multilineTextAlignment(.leading)
        .textStyle(.body.standard.regular)
      Text(login.email)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.top, 4)
        .multilineTextAlignment(.leading)
        .textStyle(.body.standard.regular)
    }
  }

  var bottonView: some View {
    VStack {
      Button(CoreL10n.kwConfirmButton) {
        isLoading = true
        completion(.confirm)
      }
      .buttonStyle(.designSystem(.titleOnly))
      .style(mood: .brand, intensity: .catchy)

      Button(CoreL10n.cancel) {
        completion(.cancel)
      }
      .buttonStyle(.designSystem(.titleOnly))
      .style(mood: .brand, intensity: .supershy)
    }
  }
}

struct DeviceToDeviceVerifyLoginView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      DeviceTransferVerifyLoginView(
        login: "_",
        progressState: .constant(.inProgress("")),
        completion: { _ in }
      )
    }
  }
}
