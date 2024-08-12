import CoreLocalization
import DesignSystem
import LoginKit
import SwiftUI
import UIComponents
import UIDelight

struct GuidedOnboardingView: View {

  @ObservedObject
  var viewModel: GuidedOnboardingViewModel

  @State
  private var showFAQ: Bool = false

  private let horizontalPadding: CGFloat = 24

  private var showNextButton: Bool {
    return viewModel.selectedAnswer != nil
  }

  private var showAltActionButton: Bool {
    viewModel.selectedAnswer?.altActionTitle != nil
  }

  var body: some View {
    FullScreenScrollView {
      VStack(spacing: 20) {
        contentView
        actionsView
        Spacer()
      }
      .animation(.default, value: viewModel.selectedAnswer)
      .padding(.top, 38)
      .padding(.bottom, 24)
      .padding(.horizontal, horizontalPadding)
      .loginAppearance(backgroundColor: .ds.background.default)
      .sheet(isPresented: $showFAQ) {
        OnboardingFAQView(questions: self.viewModel.onboardingFAQService.questions)
      }
    }
    .backgroundColorIgnoringSafeArea(.ds.background.default)
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        if showNextButton || viewModel.canGoBackToPreviousQuestion {
          backButton
        }
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        NavigationBarButton(L10n.Localizable.kwSkip) {
          viewModel.skip()
        }
      }
    }
  }

  private var backButton: some View {
    NavigationBarButton(
      CoreLocalization.L10n.Core.kwBack,
      action: {
        if viewModel.selectedAnswer != nil {
          self.viewModel.selectAnswer(nil)
        } else {
          self.viewModel.goToPreviousStep()
        }
      })
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
      Text(
        L10n.Localizable.guidedOnboardingNumberingLabel(
          String($0.currentStepIndex), String($0.totalSteps)
        ).uppercased()
      )
      .textStyle(.title.section.medium)
      .foregroundColor(.ds.text.brand.quiet)
      .fixedSize(horizontal: false, vertical: true)
      .padding(.bottom, 8)
    }
  }

  var contentView: some View {
    VStack(alignment: .leading, spacing: 16) {
      VStack(alignment: .leading, spacing: 8) {
        self.stepsNumberingLabel
        Text(self.viewModel.step.question.title)
          .textStyle(.specialty.brand.small)
          .fixedSize(horizontal: false, vertical: true)
      }

      if let animationView = animationView {
        animationView
          .cornerRadius(14)
          .id(animationView.asset)
      }

      VStack(spacing: 8) {
        ForEach(self.viewModel.answers, id: \.self) { answer in
          if viewModel.selectedAnswer == nil || viewModel.selectedAnswer == answer {
            GuidedOnboardingAnswerView(answer: answer, showDetails: viewModel.selectedAnswer != nil)
              .onTapGesture {
                viewModel.selectAnswer(answer)
              }
          }
        }
      }
    }
  }

  @ViewBuilder
  private var actionsView: some View {
    if showNextButton {
      VStack(spacing: 8.0) {
        Button(viewModel.step.nextActionTitle, action: viewModel.goToNextStep)
          .buttonStyle(.designSystem(.titleOnly))
          .opacity(showNextButton ? 1.0 : 0.0)

        if let altActionTitle = viewModel.selectedAnswer?.altActionTitle, !altActionTitle.isEmpty {
          Button(
            action: {
              self.showFAQ.toggle()
            },
            label: {
              Text(altActionTitle)
                .foregroundColor(.ds.text.brand.quiet)
            }
          )
          .buttonStyle(BorderlessActionButtonStyle())
          .opacity(showAltActionButton ? 1.0 : 0.0)
        }
      }
      .fixedSize(horizontal: false, vertical: true)
      .padding(.bottom, 24)
    }
  }
}

extension GuidedOnboardingView: NavigationBarStyleProvider {
  var navigationBarStyle: UIComponents.NavigationBarStyle {
    let appearance = UINavigationBarAppearance()
    appearance.shadowColor = .clear
    appearance.backgroundColor = .ds.background.default
    return .custom(appearance: appearance, tintColor: .ds.text.neutral.standard)
  }
}

class GuidedOnboardingView_Previews: PreviewProvider {

  static var previews: some View {
    NavigationView {
      GuidedOnboardingView(viewModel: .mock)
    }
  }
}

extension GuidedOnboardingViewModel {
  fileprivate static var mock: GuidedOnboardingViewModel {
    GuidedOnboardingViewModel(
      guidedOnboardingService: GuidedOnboardingService(
        dataProvider: GuidedOnboardingInMemoryProvider()),
      dwmOnboardingService: .mock,
      step: GuidedOnboardingSurveyStep(
        question: .howPasswordsHandled,
        answers: [
          .memorizePasswords,
          .browser,
          .somethingElse,
        ]),
      completion: nil)
  }
}
