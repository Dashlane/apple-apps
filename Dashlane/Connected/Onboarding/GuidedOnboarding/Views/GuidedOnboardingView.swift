import SwiftUI
import UIDelight
import LoginKit
import UIComponents
import DesignSystem

struct GuidedOnboardingView<Model: GuidedOnboardingViewModelProtocol>: View {

    @ObservedObject
    var viewModel: Model

    @State
    private var showFAQ: Bool = false

    private let horizontalPadding: CGFloat = 24

    var body: some View {
        GeometryReader { geo in
            FullScreenScrollView {
                VStack(spacing: 20) {
                    contentView(for: geo.size.width - (horizontalPadding * 2))
                    actionsView
                    Spacer()
                }
                .padding(.top, 38)
                .padding(.bottom, 24)
                .padding(.horizontal, horizontalPadding)
                .loginAppearance()
                .sheet(isPresented: $showFAQ, content: {
                    OnboardingFAQView(questions: self.viewModel.onboardingFAQService.questions,
                                      completion: { result in
                                        switch result {
                                        case .faqSectionShown:
                                            self.viewModel.faqSectionShown()
                                        case .questionOpened(question: let question):
                                            self.viewModel.faqQuestionSelected(question)
                                        }
                                      })
                })
            }
        }
        .backgroundColorIgnoringSafeArea(.ds.background.default)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                backButton
            }
        }
    }

    private var backButton: some View {
        NavigationBarButton(L10n.Localizable.kwBack, action: {
            if self.viewModel.hasSelectedAnswer {
                self.selectAnswer(nil)
            } else {
                self.viewModel.goToPreviousStep()
            }
        }).hidden(!viewModel.hasSelectedAnswer && !viewModel.canGoBackToPreviousQuestion)
    }

    private var animationView: LottieView? {
        if let selectedAnswer = viewModel.selectedAnswer {
            guard let animationAsset = selectedAnswer.animationAsset else {
                return nil
            }

            return LottieView(animationAsset)
        } else {
            return LottieView(self.viewModel.step.question.animationAsset)
        }
    }

    private var stepsNumberingLabel: some View {
        self.viewModel.stepNumberingDetails.map {
            Text(L10n.Localizable.guidedOnboardingNumberingLabel(String($0.currentStepIndex), String($0.totalSteps)).uppercased())
            .font(DashlaneFont.custom(20, .medium).font)
            .foregroundColor(.ds.text.brand.quiet)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 8)
        }
    }

    func contentView(for screenWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0.0) {

            self.stepsNumberingLabel

            Text(self.viewModel.step.question.title)
                .font(DashlaneFont.custom(26, .bold).font)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 16.0)
                .fixedSize()

            if let animationView = animationView {
                animationView.frame(height: screenWidth / animationView.aspectRatio)
                    .cornerRadius(14)
                    .id(animationView.asset)
                    .padding(.vertical, 16)
            }

            Spacer(minLength: 16.0)
                .fixedSize()

            VStack(spacing: 8.0) {
                ForEach(self.viewModel.answers) { answer in
                    if self.shouldShowAnswer(answer) {
                        GuidedOnboardingAnswerView(viewModel: answer)
                            .onTapGesture {
                                self.selectAnswer(answer)
                            }
                    }
                }
            }
        }
    }

    private var actionsView: some View {
        VStack(spacing: 8.0) {
            RoundedButton(viewModel.step.nextActionTitle, action: viewModel.goToNextStep)
                .roundedButtonLayout(.fill)
            .opacity(viewModel.showNextButton ? 1.0 : 0.0)

            if !viewModel.altActionTitle.isEmpty {
                Button(action: {
                    self.showFAQ.toggle()
                }, label: {
                    Text(viewModel.altActionTitle)
                        .foregroundColor(Color(asset: FiberAsset.guidedOnboardingSecondaryAction))
                })
                .buttonStyle(BorderlessActionButtonStyle())
                .opacity(viewModel.showAltActionButton ? 1.0 : 0.0)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.bottom, 24)
        .hidden(!viewModel.showNextButton)
    }

    private func selectAnswer(_ selectedAnswer: GuidedOnboardingAnswerViewModel?) {
        viewModel.selectAnswer(selectedAnswer?.content)

        let isReversed = (selectedAnswer == nil)

        if !isReversed {
            viewModel.altActionTitle = selectedAnswer?.content.altActionTitle ?? ""
        }

                        viewModel.answers.forEach { answer in
            let isSelectedAnswer = (selectedAnswer == answer)

                        withAnimation(Animation.easeInOut(duration: 0.3).delay(isReversed ? 1.2 : 0.0)) {
                answer.isInvisible = (!isSelectedAnswer && !isReversed)
                answer.tintColor = Color(asset: isSelectedAnswer ? FiberAsset.midGreen : FiberAsset.mainGreen)
            }
                        withAnimation(Animation.easeInOut(duration: 0.3).delay(isReversed ? 0.9 : 0.3)) {
                answer.isHidden = !isSelectedAnswer
            }
                        withAnimation(Animation.spring().delay(0.6)) {
                answer.isExpanded = isSelectedAnswer
            }
        }

                withAnimation(Animation.spring().delay(isReversed ? 0.9 : 0.3)) {
            viewModel.hasSelectedAnswer = !isReversed
        }
                withAnimation(Animation.easeInOut(duration: 0.3).delay(isReversed ? 0.3 : 0.9)) {
            viewModel.showNextButton = !isReversed
        }
                withAnimation(Animation.easeInOut(duration: 0.3).delay(isReversed ? 0.0 : 1.2)) {
            viewModel.showAltActionButton = (selectedAnswer?.content.altActionTitle != nil) && !isReversed
        }

    }

    private func shouldShowAnswer(_ answer: GuidedOnboardingAnswerViewModel) -> Bool {
        return (viewModel.hasSelectedAnswer && !answer.isHidden) || !self.viewModel.hasSelectedAnswer
    }
}

extension GuidedOnboardingView: NavigationBarStyleProvider {
    var navigationBarStyle: NavigationBarStyle {
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .ds.background.default
        return .custom(appearance: appearance, tintColor: .ds.text.neutral.standard)
    }
}

class GuidedOnboardingView_Previews: PreviewProvider {

    class FakeViewModel: GuidedOnboardingViewModelProtocol {
        var guidedOnboardingService: GuidedOnboardingService
        var onboardingFAQService: OnboardingFAQService = OnboardingFAQService()
        var completion: ((GuidedOnboardingViewModelCompletion) -> Void)?
        var step: GuidedOnboardingSurveyStep
        var answers: [GuidedOnboardingAnswerViewModel]
        var logService: GuidedOnboardingLogsService
        var hasSelectedAnswer: Bool = false
        var showNextButton: Bool = false
        var showAltActionButton: Bool = false
        var altActionTitle: String = ""
        var canGoBackToPreviousQuestion: Bool = false
        var selectedAnswer: GuidedOnboardingAnswer?
        var stepNumberingDetails: (totalSteps: Int, currentStepIndex: Int)? = (totalSteps: 2, currentStepIndex: 1)

        func selectAnswer(_ answer: GuidedOnboardingAnswer?) {

        }

        func cancel() {

        }

        func goToNextStep() {

        }

        func goToPreviousStep() {

        }

        func skipGuidedOnboarding() {

        }

        func faqSectionShown() {

        }

        func faqQuestionSelected(_ question: OnboardingFAQ) {

        }

        init() {
            self.guidedOnboardingService = GuidedOnboardingService(dataProvider: GuidedOnboardingInMemoryProvider())
            self.step = GuidedOnboardingSurveyStep(question: .howPasswordsHandled,
            answers: [ .memorizePasswords,
                       .browser,
                       .somethingElse ])
            self.logService = GuidedOnboardingLogsService(usageLogService: UsageLogService.fakeService)
            self.answers = step.answers.map { GuidedOnboardingAnswerViewModel(content: $0) }
        }
    }

    static var previews: some View {
        MultiContextPreview(deviceRange: .some([.iPhoneSE, .iPhone8, .iPhone11, .iPadPro])) {
            GuidedOnboardingView(viewModel: FakeViewModel())
        }
    }
}
