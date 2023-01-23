import SwiftUI
import UIDelight
import LoginKit
import UIComponents
import DesignSystem

struct DWMEmailConfirmationView<Model: DWMEmailConfirmationViewModelProtocol>: View {

    @ObservedObject
    var viewModel: Model

    @State
    var scrollingEnabled: Bool = false

    @State
    var screenHeight: CGFloat = .zero

    private let transitionHandler: GuidedOnboardingTransitionHandler?

    private var enableTapAndDragGesture: Bool { viewModel.isInFinalState && !scrollingEnabled }

    init(viewModel: Model, transitionHandler: GuidedOnboardingTransitionHandler? = nil) {
        self.viewModel = viewModel
        self.transitionHandler = transitionHandler
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .onSizeChange { size in
                    screenHeight = size.height
                }

            VStack(spacing: 0) {
                                self.animationViewIfNeeded(for: self.viewModel.state, with: screenHeight)

                self.message(for: self.viewModel.state, in: self.viewModel.context)
                Spacer()
                self.actions(for: self.viewModel.state, in: self.viewModel.context)
                    .padding(.bottom, 48)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .embedInScrollViewIfNeeded { scrollViewNeeded in
                self.scrollingEnabled = scrollViewNeeded
            }
            .loginAppearance()
            .alert(isPresented: $viewModel.shouldDisplayError) {
                Alert(title: Text(viewModel.errorContent), dismissButton: .default(Text(L10n.Localizable.kwButtonOk), action: viewModel.errorDismissalCompletion))
            }
            .onTapGesture(enabled: enableTapAndDragGesture) {
                self.transitionHandler?.dismiss()
            }
            .gesture(enableTapAndDragGesture ? dragGesture : nil)
        }
    }

    var dragGesture: some Gesture {
        return DragGesture().onChanged({ value in
            self.transitionChanged(value: value)
        }).onEnded({ _ in
            self.transitionEnded()
        })
    }

    private var loadingAnimation: some View {
        let properties: [LottieView.DynamicAnimationProperty] = [
            .init(color: FiberAsset.dwmOnboardingLoadingAnimationNeutral.color, keypath: "load.Ellipse 1.Stroke 1.Color"),
            .init(color: FiberAsset.dwmOnboardingLoadingAnimationNeutral.color, keypath: "load 2.Ellipse 1.Stroke 1.Color")
        ]

        return LottieView(.loadingAnimationProgress, loopMode: .loop, dynamicAnimationProperties: properties)
            .frame(width: 78, height: 78)
    }

    private var completionAnimation: some View {
        let properties: [LottieView.DynamicAnimationProperty] = [
            .init(color: FiberAsset.dwmOnboardingLoadingAnimationNeutral.color, keypath: "Layer 1 copy Outlines.Group 2.Fill 1.Color"),
            .init(color: FiberAsset.dwmOnboardingLoadingAnimationNeutral.color, keypath: "load 3.Ellipse 1.Stroke 1.Color")
        ]

        return LottieView(.loadingAnimationCompletion, loopMode: .playOnce, dynamicAnimationProperties: properties)
            .frame(width: 78, height: 78)
    }

    private var failureAnimation: some View {
        let properties: [LottieView.DynamicAnimationProperty] = [
            .init(color: FiberAsset.dwmOnboardingLoadingAnimationFailure.color, keypath: "load 4.Ellipse 1.Stroke 1.Color"),
            .init(color: FiberAsset.dwmOnboardingLoadingAnimationFailure.color, keypath: "Layer 1 Outlines.Group 1.Fill 1.Color")
        ]

        return LottieView(.loadingAnimationFailure, loopMode: .playOnce, dynamicAnimationProperties: properties)
            .frame(width: 78, height: 78)
    }

            private func animationViewIfNeeded(for state: DWMScanState, with screenHeight: CGFloat) -> some View {
        switch state {
        case .fetchingEmailConfirmationStatus:
            return animationContainer(for: loadingAnimation, with: screenHeight).id("loading").eraseToAnyView()
        case .emailNotConfirmedYet:
            return animationContainer(for: failureAnimation, with: screenHeight).id("failure").eraseToAnyView()
        case .breachesFound:
            return animationContainer(for: completionAnimation, with: screenHeight).id("completion").eraseToAnyView()
        case .breachesNotFound:
                        if viewModel.context == .onboardingChecklist {
                return animationContainer(for: completionAnimation, with: screenHeight).id("completion").eraseToAnyView()
            }
                        return Spacer().eraseToAnyView()
        }
    }

                                private func animationContainer<Animation: View>(for animation: Animation, with screenHeight: CGFloat) -> some View {
        return animation
            .padding(.top, screenHeight * 0.2)
            .padding(.bottom, screenHeight * 0.08)
    }

        @ViewBuilder
    private func message(for state: DWMScanState, in context: DWMOnboardingPresentationContext) -> some View {
        switch state {
        case .fetchingEmailConfirmationStatus, .emailNotConfirmedYet:
            VStack {
                self.styledTitle(state.title(for: context))
            }
        case .breachesFound, .breachesNotFound:
            VStack {
                self.styledTitle(state.title(for: context))
                self.styledSubtitle(state.subtitle(for: context))
            }
        }
    }

        @ViewBuilder
    private func actions(for state: DWMScanState, in context: DWMOnboardingPresentationContext) -> some View {
        switch state {
        case .fetchingEmailConfirmationStatus:
            cancel
        case .emailNotConfirmedYet:
            failureMenu
        case .breachesFound:
            if viewModel.context == .onboardingChecklist {
                continueButton
            } else {
                revealView(title: L10n.Localizable.darkWebMonitoringOnboardingEmailConfirmationConfirmedSwipeUp)
            }
        case .breachesNotFound:
                        if viewModel.context == .onboardingChecklist {
                continueButton
            } else {
                revealView(title: L10n.Localizable.darkWebMonitoringOnboardingEmailConfirmationNoBreachesSwipeUp)
            }
        }
    }

    @ViewBuilder
    private var failureMenu: some View {
        VStack(spacing: 16) {
            tryAgainButton
            if viewModel.context == .guidedOnboarding {
                skipButton
            } else if viewModel.context == .onboardingChecklist {
                cancel
            }
        }
    }

    private var cancel: some View {
        Button(action: self.viewModel.cancel) {
            Text(L10n.Localizable.darkWebMonitoringOnboardingEmailConfirmationFetchingCancel)
                .font(.body)
                .foregroundColor(Color(asset: FiberAsset.buttonBackgroundIncreasedContrast))
                .padding(16)
                .padding(.horizontal, 24)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var tryAgainButton: some View {
        RoundedButton(L10n.Localizable.darkWebMonitoringOnboardingEmailConfirmationFailureTryAgain,
                      action: { self.viewModel.checkEmailConfirmationStatus(userInitiated: true) })
        .roundedButtonLayout(.fill)
        .padding(.top, 20)
        .padding(.horizontal, 24)
    }

    private var skipButton: some View {
        Button(action: {
            self.viewModel.skip()
        }, label: {
            Text(L10n.Localizable.darkWebMonitoringOnboardingEmailConfirmationFailureSkip)
                .font(.body)
                .padding(16)
                .foregroundColor(Color(asset: FiberAsset.buttonBackgroundIncreasedContrast))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)
        })
    }

    private var continueButton: some View {
        Button(action: self.viewModel.emailConfirmedFromChecklist) {
            Text(L10n.Localizable.darkWebMonitoringOnboardingEmailConfirmationConfirmedContinue)
                .padding(16)
                .font(.headline)
                .foregroundColor(Color(asset: FiberAsset.buttonBackgroundIncreasedContrast))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)
        }
    }

    private var revealButton: some View {
        Button(action: { self.transitionHandler?.dismiss() }, label: {
            Text(L10n.Localizable.kwCmContinue)
                .font(.headline)
                .padding(.top, 16)
                .foregroundColor(Color(asset: FiberAsset.buttonBackgroundIncreasedContrast))
                .fixedSize(horizontal: false, vertical: true)
        })
    }

    private func revealView(title: String) -> some View {
        VStack {
            if scrollingEnabled {
                revealButton
            } else {
                HStack(spacing: 24.0) {
                    Image(asset: FiberAsset.arrowUp)
                        .colorMultiply(Color(asset: FiberAsset.pageControlSelected))
                    Text(title)
                        .font(.body)
                        .foregroundColor(Color(asset: FiberAsset.mainCopy))
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                    Image(asset: FiberAsset.arrowUp)
                        .colorMultiply(Color(asset: FiberAsset.pageControlSelected))
                }
            }
        }
        .padding(.horizontal, 24)
    }

    private func styledTitle(_ string: String) -> some View {
        Text(string)
            .multilineTextAlignment(.center)
            .font(.custom(GTWalsheimPro.bold.name, size: 26, relativeTo: .title))
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 24)
    }

    private func styledSubtitle(_ string: String) -> some View {
        Text(string)
            .multilineTextAlignment(.center)
            .font(.body)
            .foregroundColor(Color(asset: FiberAsset.guidedOnboardingSecondaryText))
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 30)
    }

    private func transitionEnded() {
        transitionHandler?.update(state: .end)
    }

    private func transitionChanged(value: DragGesture.Value) {
        transitionHandler?.update(state: .changed(value))
    }
}

extension DWMEmailConfirmationView: NavigationBarStyleProvider {
    var navigationBarStyle: NavigationBarStyle {
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        appearance.backgroundColor = FiberAsset.searchBarBackgroundInactive.color
        return .custom(appearance: appearance, tintColor: FiberAsset.dashGreenCopy.color)
    }
}

private extension DWMScanState {
    func title(for context: DWMOnboardingPresentationContext) -> String {
        switch self {
        case .fetchingEmailConfirmationStatus:
            return L10n.Localizable.darkWebMonitoringOnboardingEmailConfirmationFetchingTitle
        case .emailNotConfirmedYet:
            return L10n.Localizable.darkWebMonitoringOnboardingEmailConfirmationFailureTitle
        case .breachesFound:
            return L10n.Localizable.darkWebMonitoringOnboardingEmailConfirmationConfirmedTitle
        case .breachesNotFound:
            switch context {
            case .onboardingChecklist:
                return L10n.Localizable.darkWebMonitoringOnboardingEmailConfirmationConfirmedTitle
            case .guidedOnboarding:
                return L10n.Localizable.darkWebMonitoringOnboardingEmailConfirmationNoBreachesTitle
            }
        }
    }

    func subtitle(for context: DWMOnboardingPresentationContext) -> String {
        switch self {
        case .fetchingEmailConfirmationStatus:
            return ""
        case .emailNotConfirmedYet:
            return ""
        case .breachesFound:
            return L10n.Localizable.darkWebMonitoringOnboardingEmailConfirmationConfirmedSubtitle
        case .breachesNotFound:
            switch context {
            case .onboardingChecklist:
                return L10n.Localizable.darkWebMonitoringOnboardingEmailConfirmationConfirmedSubtitle
            case .guidedOnboarding:
                return L10n.Localizable.darkWebMonitoringOnboardingEmailConfirmationNoBreachesSubtitle
            }
        }
    }
}

struct DWMEmailConfirmationView_Previews: PreviewProvider {
    class FakeModel: DWMEmailConfirmationViewModelProtocol {
        @Published
        var state: DWMScanState
        var context: DWMOnboardingPresentationContext = .guidedOnboarding

        @Published
        var shouldShowMailAppsMenu: Bool = false

        @Published
        var shouldDisplayError: Bool = false
        var errorContent: String = ""
        var errorDismissalCompletion: (() -> Void)?

        var isInFinalState: Bool = false

        func skip() {}
        func cancel() {}
        func checkEmailConfirmationStatus(userInitiated: Bool) {}
        func emailConfirmedFromChecklist() {}

        init(state: DWMScanState) {
            self.state = state
        }
    }

    static var previews: some View {
        MultiContextPreview(deviceRange: .some([.iPhoneSE]), dynamicTypePreview: true) {
            DWMEmailConfirmationView(viewModel: FakeModel(state: .fetchingEmailConfirmationStatus))
            DWMEmailConfirmationView(viewModel: FakeModel(state: .emailNotConfirmedYet))
            DWMEmailConfirmationView(viewModel: FakeModel(state: .breachesFound))
            DWMEmailConfirmationView(viewModel: FakeModel(state: .breachesNotFound))
        }
    }
}
