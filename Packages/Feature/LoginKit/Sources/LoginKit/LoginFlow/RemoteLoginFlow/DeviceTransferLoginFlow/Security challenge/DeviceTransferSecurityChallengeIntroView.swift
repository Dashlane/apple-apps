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
        LottieProgressionFeedbacksView(state: model.progressState)
      } else {
        mainView
        overlayView
      }
    }
    .navigationTitle(CoreL10n.deviceToDeviceNavigationTitle)
    .navigationBarTitleDisplayMode(.inline)
    .loginAppearance()
    .reportPageAppearance(.loginDeviceTransferSecurityChallenge)
  }

  var mainView: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        Text(CoreL10n.Mpless.D2d.Universal.untrustedIntroTitle)
          .foregroundStyle(Color.ds.text.neutral.catchy)
          .font(.title)
        Infobox(CoreL10n.Mpless.D2d.Universal.untrustedIntroInfoboxTitle)
        InstructionsCardView(
          cardContent: [
            CoreL10n.Mpless.D2d.Universal.untrustedIntroMessage1,
            CoreL10n.Mpless.D2d.Universal.untrustedIntroMessage2,
            CoreL10n.Mpless.D2d.Universal.untrustedIntroMessage3,
          ]
        )
        Spacer()
      }
      .padding(24)
    }
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
  }

  var overlayView: some View {
    VStack {
      Spacer()
      Button(CoreL10n.Mpless.D2d.Universal.untrustedIntroCta) {
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
