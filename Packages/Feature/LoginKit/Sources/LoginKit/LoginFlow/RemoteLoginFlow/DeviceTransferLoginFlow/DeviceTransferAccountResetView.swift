import CoreLocalization
import CoreTypes
import DesignSystem
import Foundation
import SwiftUI
import UIDelight

struct DeviceTransferAccountResetView: View {

  @Environment(\.openURL) private var openURL

  var body: some View {
    ZStack {
      mainView
      overlayView
    }
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle(CoreL10n.deviceToDeviceNavigationTitle)
    .loginAppearance()
  }

  var mainView: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        Text(CoreL10n.Mpless.D2d.Untrusted.resetIntroTitle)
          .textStyle(.title.section.large)
          .foregroundStyle(Color.ds.text.neutral.catchy)
        MarkdownText(CoreL10n.Mpless.D2d.Untrusted.resetIntroMessage)
          .textStyle(.body.standard.regular)
          .foregroundStyle(Color.ds.text.neutral.standard)
        Spacer()
      }
      .padding(24)
    }
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
  }

  var overlayView: some View {
    VStack(spacing: 8) {
      Spacer()
      Button(CoreL10n.Mpless.D2d.Untrusted.resetIntroPrimaryCta) {
        openURL(DashlaneURLFactory.resetAccountInfo)
      }
      .buttonStyle(.designSystem(.titleOnly))
      .style(mood: .brand, intensity: .catchy)

      Button(CoreL10n.Mpless.D2d.Untrusted.resetIntroSecondaryCta) {
        openURL(DashlaneURLFactory.accountRecoveryInfo)
      }
      .buttonStyle(.designSystem(.titleOnly))
      .style(mood: .brand, intensity: .quiet)

    }
    .padding(24)
  }
}

struct AccountResetView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      DeviceTransferAccountResetView()
    }
  }
}
