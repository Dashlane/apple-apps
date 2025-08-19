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
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
    .overlay(overlayButton)
  }

  var mainView: some View {
    VStack(alignment: .leading, spacing: 33) {
      DS.ExpressiveIcon(.ds.recoveryKey.outlined)
        .style(mood: .brand, intensity: .quiet)
        .controlSize(.extraLarge)
      VStack(alignment: .leading, spacing: 16) {
        Text(L10n.Localizable.postLoginRecoveryKeyDisabledTitle)
          .multilineTextAlignment(.leading)
          .lineLimit(nil)
          .fixedSize(horizontal: false, vertical: true)
          .textStyle(.title.section.large)
          .foregroundStyle(Color.ds.text.neutral.catchy)
        textBody(Text(L10n.Localizable.postLoginRecoveryKeyDisabledMpMessage))
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
            .frame(maxWidth: .infinity)
        })

      Button(
        action: {
          dismiss()
        },
        label: {
          Text(L10n.Localizable.postLoginRecoveryKeyDisabledCancel)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
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
      .foregroundStyle(Color.ds.text.neutral.standard)
      .font(.body)
  }
}

struct PostAccountRecoveryLoginDisabledView_Previews: PreviewProvider {
  static var previews: some View {
    AccountRecoveryKeyDisabledAlertView(
      model: AccountRecoveryKeyDisabledAlertViewModel(
        authenticationMethod: .masterPassword(""), deeplinkService: DeepLinkingService.fakeService))
  }
}
