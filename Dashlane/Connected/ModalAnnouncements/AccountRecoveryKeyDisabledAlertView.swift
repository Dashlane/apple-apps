import CoreSession
import DesignSystem
import Foundation
import SwiftUI
import UIComponents

struct AccountRecoveryKeyDisabledAlertView: View {

  let model: AccountRecoveryKeyDisabledAlertViewModel

  @Environment(\.dismiss)
  var dismiss

  var body: some View {
    ScrollView {
      mainView
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
    .backgroundColorIgnoringSafeArea(.ds.background.alternate)
    .overlay(overlayButton)
  }

  var mainView: some View {
    VStack(alignment: .leading, spacing: 33) {
      Image.ds.recoveryKey.outlined
        .resizable()
        .frame(width: 77, height: 77)
        .foregroundColor(.ds.text.brand.quiet)
        .padding(.horizontal, 16)
      VStack(alignment: .leading, spacing: 16) {
        Text(L10n.Localizable.postLoginRecoveryKeyDisabledTitle)
          .multilineTextAlignment(.leading)
          .lineLimit(nil)
          .fixedSize(horizontal: false, vertical: true)
          .font(
            .custom(
              GTWalsheimPro.regular.name,
              size: 28,
              relativeTo: .title
            )
            .weight(.medium)
          )
          .foregroundColor(.ds.text.neutral.catchy)
        textBody(Text(model.authenticationMethod.message))
        textBody(Text(L10n.Localizable.postLoginRecoveryKeyDisabledMessage))
          .padding(.top, 16)
      }
      Spacer()
    }.padding(.all, 24)
      .padding(.bottom, 24)
  }

  var overlayButton: some View {
    VStack(spacing: 8) {
      Spacer()
      Button(
        action: {
          model.goToSettings()
          dismiss()
        },
        label: {
          Text(L10n.Localizable.postLoginRecoveryKeyDisabledCta)
            .fixedSize(horizontal: false, vertical: true)
        })

      Button(
        action: {
          dismiss()
        },
        label: {
          Text(L10n.Localizable.postLoginRecoveryKeyDisabledCancel)
            .fixedSize(horizontal: false, vertical: true)
        }
      )
      .style(mood: .brand, intensity: .quiet)
    }
    .buttonStyle(.designSystem(.titleOnly))
    .padding(.horizontal, 24)
    .padding(.bottom, 24)
  }

  @ViewBuilder
  func textBody(_ text: Text) -> some View {
    text
      .multilineTextAlignment(.leading)
      .lineLimit(nil)
      .fixedSize(horizontal: false, vertical: true)
      .foregroundColor(.ds.text.neutral.standard)
      .font(.body)
  }
}

struct PostAccountRecoveryLoginDisabledView_Previews: PreviewProvider {
  static var previews: some View {
    AccountRecoveryKeyDisabledAlertView(
      model: AccountRecoveryKeyDisabledAlertViewModel(
        authenticationMethod: .masterPassword(""), deeplinkService: DeepLinkingService.fakeService))
    AccountRecoveryKeyDisabledAlertView(
      model: AccountRecoveryKeyDisabledAlertViewModel(
        authenticationMethod: .invisibleMasterPassword(""),
        deeplinkService: DeepLinkingService.fakeService))
  }
}

extension AuthenticationMethod {
  fileprivate var message: String {
    switch self {
    case .invisibleMasterPassword, .sso:
      return L10n.Localizable.postLoginRecoveryKeyDisabledMplessMessage
    case .masterPassword:
      return L10n.Localizable.postLoginRecoveryKeyDisabledMpMessage
    }
  }
}
