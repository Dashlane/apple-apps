import CoreLocalization
import DesignSystem
import SwiftUI
import SwiftUILottie
import UIComponents
import UIDelight

struct FreeTrialStartView: View {

  let daysLeft: Int
  let learnMore: () -> Void

  @Environment(\.dismiss) var dismiss

  var body: some View {
    ViewThatFits {
      ScrollView {
        content
      }
      content
    }
    .padding()
    .background(Color.ds.background.default, ignoresSafeAreaEdges: .all)
    .overlay(AnnouncementCloseButton(dismiss: { dismiss() }), alignment: .topTrailing)
    .navigationBarBackButtonHidden(true)
    .reportPageAppearance(.freeTrialStarted)
  }

  var content: some View {
    VStack(spacing: 5) {
      Spacer()

      LottieView(.diamond, loopMode: .loop, animated: true)
        .scaleEffect(1.6)
        .frame(width: 218, height: 163, alignment: .center)
      Text(CoreL10n.freeTrialStartedDialogTitle)
        .textStyle(.title.section.large)
        .foregroundStyle(Color.ds.text.neutral.catchy)
        .multilineTextAlignment(.leading)
        .padding(.top, 5)
      Text(CoreL10n.freeTrialStartedDialogDescriptionDaysleft(daysLeft))
        .textStyle(.body.standard.regular)
        .foregroundStyle(Color.ds.text.neutral.standard)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.top, 24)

      Spacer()

      Button(CoreL10n.freeTrialStartedDialogLearnMoreCta, action: learnMore)
        .buttonStyle(.designSystem(.titleOnly))
        .padding(.top, 12)
    }
    .frame(maxHeight: .infinity)
  }
}

struct FreeTrialStartView_Previews: PreviewProvider {
  static var previews: some View {
    FreeTrialStartView(daysLeft: 5, learnMore: {})
  }
}
