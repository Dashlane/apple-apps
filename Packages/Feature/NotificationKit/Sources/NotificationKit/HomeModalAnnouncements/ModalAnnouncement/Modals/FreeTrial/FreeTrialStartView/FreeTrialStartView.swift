import CoreLocalization
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

struct FreeTrialStartView: View {

  let daysLeft: Int
  let learnMore: () -> Void

  @Environment(\.dismiss) var dismiss

  var body: some View {
    ScrollView {
      VStack(spacing: 5) {
        Spacer()
        LottieView(.diamond, loopMode: .loop, animated: true)
          .scaleEffect(1.6)
          .frame(width: 218, height: 163, alignment: .center)
        Text(L10n.Core.freeTrialStartedDialogTitle)
          .textStyle(.title.section.large)
          .foregroundColor(.ds.text.neutral.catchy)
          .multilineTextAlignment(.leading)
          .padding(.top, 5)
        Text(L10n.Core.freeTrialStartedDialogDescriptionDaysleft(daysLeft))
          .textStyle(.body.standard.regular)
          .foregroundColor(.ds.text.neutral.standard)
          .fixedSize(horizontal: false, vertical: true)
          .padding(.top, 24)

        Spacer()
        Button(L10n.Core.freeTrialStartedDialogLearnMoreCta, action: learnMore)
          .buttonStyle(.designSystem(.titleOnly))
          .padding(.top, 12)
      }
    }
    .padding()
    .backgroundColorIgnoringSafeArea(.ds.background.default)
    .overlay(AnnouncementCloseButton(dismiss: { dismiss() }), alignment: .topTrailing)
    .navigationBarBackButtonHidden(true)
    .reportPageAppearance(.freeTrialStarted)
  }
}

struct FreeTrialStartView_Previews: PreviewProvider {
  static var previews: some View {
    FreeTrialStartView(daysLeft: 5, learnMore: {})
  }
}
