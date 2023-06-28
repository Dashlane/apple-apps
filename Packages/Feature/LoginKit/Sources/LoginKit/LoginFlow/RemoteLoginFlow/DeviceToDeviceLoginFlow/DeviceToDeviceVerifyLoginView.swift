import Foundation
import SwiftUI
import UIComponents
import DesignSystem
import CoreSession
import DashlaneAPI
import CoreLocalization

#if canImport(UIKit)
struct DeviceToDeviceVerifyLoginView: View {

    @StateObject
    var model: DeviceToDeviceVerifyLoginViewModel

    @Binding
    var progressState: ProgressionState

    @Environment(\.dismiss)
    var dismiss

    var body: some View {
        ZStack {
            if model.isLoading {
                ProgressionView(state: $progressState)
            } else {
                loginView
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .loginAppearance()
        .animation(.default, value: model.isLoading)
            .navigationBarBackButtonHidden()
            .navigationTitle(L10n.Core.deviceToDeviceNavigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarStyle(.transparent)
            .overFullScreen(isPresented: $model.showError) {
                FeedbackView(title: L10n.Core.deviceToDeviceLoginLoadErrorTitle, message: L10n.Core.deviceToDeviceLoginLoadErrorMessage, primaryButton: (L10n.Core.deviceToDeviceLoginErrorRetry, {
                    model.isLoading = false
                    model.showError = false
 }), secondaryButton: (CoreLocalization.L10n.Core.cancel, {
                    model.showError = false
                    model.completion(.cancel)}))
            }
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
            Text(model.loginData.login)
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
            RoundedButton(L10n.Core.kwConfirmButton, action: {
                model.confirm()
            })
            .style(mood: .brand, intensity: .catchy)
            .roundedButtonLayout(.fill)
            Button(action: {
                model.cancel()
            }, title: L10n.Core.cancel)
                .buttonStyle(.borderless)
                .foregroundColor(.ds.text.brand.standard)
        }.padding(.horizontal, 24)
    }
}

struct DeviceToDeviceVerifyLoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DeviceToDeviceVerifyLoginView(
                model: DeviceToDeviceVerifyLoginViewModel(
                    loginData: DevciceToDeviceTransferData(
                        key: .init(
                            type: .masterPassword,
                            value: "Dashlane12"
                        ),
                        token: "",
                        login: "_",
                        version: 1
                    ),
                    sessionCleaner: .mock,
                    loginHandler: .mock,
                    completion: {_ in}),
                progressState: .constant(.inProgress(""))
            )
        }
    }
}
#endif
