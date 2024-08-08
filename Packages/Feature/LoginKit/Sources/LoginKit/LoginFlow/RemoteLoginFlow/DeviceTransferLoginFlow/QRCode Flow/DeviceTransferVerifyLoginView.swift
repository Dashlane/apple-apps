import CoreLocalization
import CoreSession
import DashTypes
import DashlaneAPI
import DesignSystem
import Foundation
import SwiftUI
import UIComponents

#if canImport(UIKit)
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
          ProgressionView(state: $progressState)
        } else {
          loginView
        }
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 24)
      .loginAppearance()
      .animation(.default, value: isLoading)
      .navigationBarBackButtonHidden()
      .navigationTitle(L10n.Core.deviceToDeviceNavigationTitle)
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarStyle(.transparent)
    }

    @ViewBuilder
    var loginView: some View {
      topView
        .overlay(bottonView)
    }

    @ViewBuilder
    var topView: some View {
      VStack(alignment: .leading, spacing: 8) {
        Text(L10n.Core.deviceToDeviceVerifyLoginTitle)
          .foregroundColor(.ds.text.neutral.catchy)
          .font(.custom(GTWalsheimPro.bold.name, size: 26, relativeTo: .title))
          .multilineTextAlignment(.leading)
        Text(L10n.Core.deviceToDeviceVerifyLoginMessage)
          .foregroundColor(.ds.text.neutral.standard)
          .padding(.top, 4)
          .multilineTextAlignment(.leading)
        Text(login.email)
          .fixedSize(horizontal: false, vertical: true)
          .padding(.top, 4)
          .multilineTextAlignment(.leading)
        Spacer()
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 24)
    }

    var bottonView: some View {
      VStack(spacing: 23) {
        Spacer()
        Button(L10n.Core.kwConfirmButton) {
          isLoading = true
          completion(.confirm)
        }
        .buttonStyle(.designSystem(.titleOnly))
        .style(mood: .brand, intensity: .catchy)

        Button(L10n.Core.cancel) {
          completion(.cancel)
        }
        .buttonStyle(.borderless)
        .foregroundColor(.ds.text.brand.standard)
      }
      .padding(.horizontal, 24)
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
#endif
