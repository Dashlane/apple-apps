import CoreLocalization
import DesignSystem
import Foundation
import SwiftUI
import UIDelight

struct DeviceTransferAccountRecoveryIntroView: View {

  enum CompletionType {
    case startRecovery
    case startLostKey
  }

  let completion: (CompletionType) -> Void

  var body: some View {
    ZStack {
      mainView
      overlayView
    }
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle(L10n.Core.deviceToDeviceNavigationTitle)
    .loginAppearance()
    .reportPageAppearance(.loginDeviceTransferAccountRecoveryKey)
  }

  var mainView: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        Text(L10n.Core.Mpless.D2d.Untrusted.recoveryIntroTitle)
          .textStyle(.title.section.large)
          .foregroundStyle(Color.ds.text.neutral.catchy)
        MarkdownText(L10n.Core.Mpless.D2d.Untrusted.recoveryIntroMessage)
          .textStyle(.body.standard.regular)
          .foregroundStyle(Color.ds.text.neutral.standard)
        Spacer()
      }
      .padding(24)
    }
    .backgroundColorIgnoringSafeArea(.ds.background.alternate)
  }

  var overlayView: some View {
    VStack(spacing: 8) {
      Spacer()
      Button(L10n.Core.Mpless.D2d.Untrusted.recoveryIntroPrimaryCta) {
        completion(.startRecovery)
      }
      .style(mood: .brand, intensity: .catchy)

      Button(L10n.Core.Mpless.D2d.Untrusted.recoveryIntroSecondaryCta) {
        completion(.startLostKey)
      }
      .style(mood: .brand, intensity: .quiet)
    }
    .buttonStyle(.designSystem(.titleOnly))
    .padding(24)
  }
}

struct AccountRecoveryIntroView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      DeviceTransferAccountRecoveryIntroView { _ in }
    }
  }
}
