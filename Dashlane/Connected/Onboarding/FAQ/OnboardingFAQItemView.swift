import SwiftUI
import UIDelight

struct OnboardingFAQItemView: View {

    var question: OnboardingFAQ

    @State
    var showDetails = false

    enum Completion {
        case opened(_ question: OnboardingFAQ)
    }

    var completion: ((Completion) -> Void)?

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 16.0) {
                Text(question.title)
                    .font(.system(size: 17.0))
                    .fixedSize(horizontal: false, vertical: true)

                Text(question.description)
                    .font(.system(size: 15.0))
                    .fixedSize(horizontal: false, vertical: true)
                    .hidden(!showDetails)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Image(asset: FiberAsset.arrowUp)
                    .rotationEffect(.degrees(showDetails ? 0.0 : 180.0), anchor: .center)
                    .colorMultiply(Color(asset: FiberAsset.onboardingSecondaryText))
            }.offset(y: 7.0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16.0)
        .background(Color(asset: FiberAsset.listBackground))
        .cornerRadius(4.0)
        .onTapGesture {
            withAnimation(.spring()) {
                self.showDetails.toggle()
            }

            if self.showDetails {
                self.completion?(.opened(self.question))
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
