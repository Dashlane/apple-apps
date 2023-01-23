import SwiftUI
import UIDelight
import UIComponents

struct OnboardingFAQView: View {
    var questions: [OnboardingFAQ]

    enum Completion {
        case faqSectionShown
        case questionOpened(question: OnboardingFAQ)
    }

    var completion: ((Completion) -> Void)?

    var body: some View {
        VStack {
            topView
            ScrollView {
                VStack(spacing: 0) {
                    contentView
                }
            }
        }
        .background(Color(asset: FiberAsset.buttonTextIncreasedContrast))
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            self.completion?(.faqSectionShown)
        }
    }

    var topView: some View {
        HStack {
            Spacer()
            Rectangle()
                .frame(width: 35, height: 5)
                .cornerRadius(16)
                .foregroundColor(Color(asset: FiberAsset.grey04))
            Spacer()
        }.padding(.top, 6)
    }

    var contentView: some View {
        VStack(alignment: .leading, spacing: 40.0) {
            Text(L10n.Localizable.guidedOnboardingFAQTitle)
                .font(DashlaneFont.custom(26, .bold).font)
                .fixedSize(horizontal: false, vertical: true)

            VStack {
                ForEach(questions, id: \.rawValue) { question in
                    OnboardingFAQItemView(question: question) { result in
                        switch result {
                        case let .opened(question):
                            self.completion?(.questionOpened(question: question))
                        }
                    }
                }
            }
        }.padding(25.0)
    }
}

struct OnboardingFAQView_Previews: PreviewProvider {

    static var previews: some View {
        MultiContextPreview {
            OnboardingFAQView(questions: OnboardingFAQService().questions)
        }
    }
}
