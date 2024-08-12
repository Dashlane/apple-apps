import CoreLocalization
import DesignSystem
import Foundation
import SwiftUI
import UIComponents

struct DeviceTransferSecurityChallengeIntroView: View {

  @StateObject
  var model: DeviceTransferSecurityChallengeIntroViewModel

  init(model: @escaping @autoclosure () -> DeviceTransferSecurityChallengeIntroViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    ZStack {
      if model.isLoading {
        ProgressionView(state: $model.progressState)
      } else {
        mainView
        overlayView
      }
    }
    .navigationBarStyle(.transparent)
    .navigationTitle(L10n.Core.deviceToDeviceNavigationTitle)
    .navigationBarTitleDisplayMode(.inline)
    .loginAppearance()
    .reportPageAppearance(.loginDeviceTransferSecurityChallenge)
  }

  var mainView: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        Text(L10n.Core.Mpless.D2d.Universal.untrustedIntroTitle)
          .foregroundColor(.ds.text.neutral.catchy)
          .font(.title)
        Infobox(L10n.Core.Mpless.D2d.Universal.untrustedIntroInfoboxTitle)
        InstructionsCardView(
          cardContent: [
            L10n.Core.Mpless.D2d.Universal.untrustedIntroMessage1,
            L10n.Core.Mpless.D2d.Universal.untrustedIntroMessage2,
            L10n.Core.Mpless.D2d.Universal.untrustedIntroMessage3,
          ]
        )
        Spacer()
      }
      .padding(24)
    }
    .backgroundColorIgnoringSafeArea(.ds.background.alternate)
  }

  var overlayView: some View {
    VStack {
      Spacer()
      Button(L10n.Core.Mpless.D2d.Universal.untrustedIntroCta) {
        Task {
          await model.recover()
        }
      }
      .style(mood: .brand, intensity: .quiet)
      .buttonStyle(.designSystem(.titleOnly))
    }
    .padding(24)
  }

}

#Preview {
  NavigationView {
    DeviceTransferSecurityChallengeIntroView(model: .mock)
  }
}
