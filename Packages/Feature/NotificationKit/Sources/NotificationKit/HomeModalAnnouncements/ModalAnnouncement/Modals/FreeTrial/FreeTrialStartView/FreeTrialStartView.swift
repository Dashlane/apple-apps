import SwiftUI
import UIDelight
import UIComponents
import DesignSystem
import CoreLocalization

struct FreeTrialStartView: View {

    var learnMore: () -> Void

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 5) {
            Spacer()
            LottieView(.diamond, loopMode: .loop, animated: true)
                .scaleEffect(1.6)
                .frame(width: 218, height: 163, alignment: .center)
            Text(L10n.Core.freeTrialStartedDialogTitle)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
                .padding(.top, 5)
            Text(L10n.Core.freeTrialStartedDialogDescription)
                .font(.callout)
                .foregroundColor(.ds.text.neutral.standard)
            Spacer()
            RoundedButton(L10n.Core.freeTrialStartedDialogLearnMoreCta, action: learnMore)
                .roundedButtonLayout(.fill)
                .padding(.top, 12)
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
        FreeTrialStartView(learnMore: {})
    }
}
