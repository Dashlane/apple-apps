import DesignSystem
import SwiftUI
import UIDelight

struct OnboardingFAQItemView: View {

    var question: OnboardingFAQ

    @State
    var showDetails = false

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 16.0) {
                Text(question.title)
                    .font(.system(size: 17.0))
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(.ds.text.neutral.standard)

                Text(question.description)
                    .font(.system(size: 15.0))
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(.ds.text.neutral.quiet)
                    .hidden(!showDetails)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Image.ds.caretUp.outlined
                    .rotationEffect(.degrees(showDetails ? 0.0 : 180.0), anchor: .center)
                    .colorMultiply(.ds.text.neutral.quiet)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16.0)
        .background(Color.ds.container.expressive.neutral.quiet.idle)
        .cornerRadius(4.0)
        .onTapGesture {
            withAnimation(.spring()) {
                self.showDetails.toggle()
            }
        }
    }
}

struct OnboardingFAQItemView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            OnboardingFAQItemView(question: .whatIfDashlaneGetsHacked)
        }.previewLayout(.sizeThatFits)
    }
}
