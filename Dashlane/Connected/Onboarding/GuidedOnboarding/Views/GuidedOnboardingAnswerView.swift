import SwiftUI
import UIDelight
import DesignSystem

struct GuidedOnboardingAnswerView: View {

    let answer: GuidedOnboardingAnswer
    let showDetails: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 18.0) {
            VStack(alignment: .leading, spacing: 16.0) {
                Text(answer.title)
                    .textStyle(.body.standard.strong)
                    .foregroundColor(.ds.text.brand.standard)
                    .accessibilityAddTraits(showDetails ? .isStaticText : .isButton)
                Text(answer.description)
                    .textStyle(.body.standard.regular)
                    .foregroundColor(.ds.text.neutral.standard)
                    .lineSpacing(1.35)
                    .fixedSize(horizontal: false, vertical: true)
                    .hidden(!showDetails)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(EdgeInsets(top: 26, leading: 16, bottom: 26, trailing: 16))
        .background(.ds.container.agnostic.neutral.quiet)
        .cornerRadius(8.0)
    }
}

struct GuidedOnboardingAnswerView_Previews: PreviewProvider {
    static var previews: some View {
        GuidedOnboardingAnswerView(answer: .autofill, showDetails: false)
        GuidedOnboardingAnswerView(answer: .autofill, showDetails: true)
    }
 }
