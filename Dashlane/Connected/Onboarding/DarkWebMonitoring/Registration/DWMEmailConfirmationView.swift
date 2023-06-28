import SwiftUI
import UIDelight
import LoginKit
import UIComponents
import DesignSystem
import CoreLocalization

struct DWMEmailConfirmationView: View {

    enum Action {
        case cancel
        case skip
        case unexpectedError
    }

    @ObservedObject
    var viewModel: DWMEmailConfirmationViewModel

    let transitionHandler: GuidedOnboardingTransitionHandler?
    let action: (Action) -> Void

    @State
    var scrollingEnabled: Bool = false

    @State
    var screenHeight: CGFloat = .zero

    private var enableTapAndDragGesture: Bool { viewModel.isInFinalState && !scrollingEnabled }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .onSizeChange { size in
                    screenHeight = size.height
                }

            VStack(spacing: 0) {
                                self.animationViewIfNeeded(for: self.viewModel.state, with: screenHeight)

                message(for: viewModel.state)
                Spacer()
                actions(for: viewModel.state)
                    .padding(.bottom, 48)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .embedInScrollViewIfNeeded { scrollViewNeeded in
                self.scrollingEnabled = scrollViewNeeded
            }
            .loginAppearance(backgroundColor: .ds.background.default)
            .alert(item: $viewModel.alert) { alert in
                Alert(
                    title: Text(alert.message),
                    dismissButton: .default(Text(CoreLocalization.L10n.Core.kwButtonOk)) {
                        if alert.isUnexpected {
                            action(.unexpectedError)
                        }
                    }
                )
            }
            .onTapGesture(enabled: enableTapAndDragGesture) {
                self.transitionHandler?.dismiss()
            }
            .gesture(enableTapAndDragGesture ? dragGesture : nil)
        }
        .navigationBarHidden(true)
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

            private func animationViewIfNeeded(for state: DWMEmailConfirmationViewModel.ScanState, with screenHeight: CGFloat) -> some View {
        switch state {
        case .fetchingEmailConfirmationStatus:
            return animationContainer(for: loadingAnimation, with: screenHeight).id("loading").eraseToAnyView()
        case .emailNotConfirmedYet:
            return animationContainer(for: failureAnimation, with: screenHeight).id("failure").eraseToAnyView()
        case .breachesFound:
            return animationContainer(for: completionAnimation, with: screenHeight).id("completion").eraseToAnyView()
        case .breachesNotFound:
                        return Spacer().eraseToAnyView()
        }
    }

                                private func animationContainer<Animation: View>(for animation: Animation, with screenHeight: CGFloat) -> some View {
        return animation
            .padding(.top, screenHeight * 0.2)
            .padding(.bottom, screenHeight * 0.08)
    }

        @ViewBuilder
    private func message(for state: DWMEmailConfirmationViewModel.ScanState) -> some View {
        switch state {
        case .fetchingEmailConfirmationStatus, .emailNotConfirmedYet:
            VStack {
                self.styledTitle(state.title)
            }
        case .breachesFound, .breachesNotFound:
            VStack {
                self.styledTitle(state.title)
                self.styledSubtitle(state.subtitle)
            }
        }
    }

        @ViewBuilder
    private func actions(for state: DWMEmailConfirmationViewModel.ScanState) -> some View {
        switch state {
        case .fetchingEmailConfirmationStatus:
            cancel
        case .emailNotConfirmedYet:
            failureMenu
        case .breachesFound:
            revealView(title: L10n.Localizable.darkWebMonitoringOnboardingEmailConfirmationConfirmedSwipeUp)
        case .breachesNotFound:
            revealView(title: L10n.Localizable.darkWebMonitoringOnboardingEmailConfirmationNoBreachesSwipeUp)
        }
    }

    @ViewBuilder
    private var failureMenu: some View {
        VStack(spacing: 16) {
            tryAgainButton
            skipButton
        }
    }

    private var cancel: some View {
        Button(
            action: {
                viewModel.cancel()
                action(.cancel)
            }, label: {
                Text(L10n.Localizable.darkWebMonitoringOnboardingEmailConfirmationFetchingCancel)
                    .font(.body)
                    .foregroundColor(.ds.text.brand.standard)
                    .padding(16)
                    .padding(.horizontal, 24)
                    .fixedSize(horizontal: false, vertical: true)
            }
        )
    }

    private var tryAgainButton: some View {
        RoundedButton(L10n.Localizable.darkWebMonitoringOnboardingEmailConfirmationFailureTryAgain,
                      action: { self.viewModel.checkEmailConfirmationStatus() })
        .roundedButtonLayout(.fill)
        .padding(.top, 20)
        .padding(.horizontal, 24)
    }

    private var skipButton: some View {
        Button(
            action: {
                viewModel.skip()
                action(.skip)
            }, label: {
                Text(L10n.Localizable.darkWebMonitoringOnboardingEmailConfirmationFailureSkip)
                    .font(.body)
                    .padding(16)
                    .foregroundColor(.ds.text.brand.standard)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)
            }
        )
    }

    private var revealButton: some View {
        Button(action: { self.transitionHandler?.dismiss() }, label: {
            Text(L10n.Localizable.kwCmContinue)
                .font(.headline)
                .padding(.top, 16)
                .foregroundColor(.ds.text.brand.standard)
                .fixedSize(horizontal: false, vertical: true)
        })
    }

    private func revealView(title: String) -> some View {
        VStack {
            if scrollingEnabled {
                revealButton
            } else {
                HStack(spacing: 24.0) {
                    Image.ds.caretUp.outlined
                        .colorMultiply(Color(asset: FiberAsset.pageControlSelected))
                    Text(title)
                        .font(.body)
                        .foregroundColor(.ds.text.neutral.catchy)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                    Image.ds.caretUp.outlined
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
    var navigationBarStyle: UIComponents.NavigationBarStyle {
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        appearance.backgroundColor = FiberAsset.searchBarBackgroundInactive.color
        return .custom(appearance: appearance, tintColor: FiberAsset.dashGreenCopy.color)
    }
}

private extension DWMEmailConfirmationViewModel.ScanState {
    var title: String {
        switch self {
        case .fetchingEmailConfirmationStatus:
            return L10n.Localizable.darkWebMonitoringOnboardingEmailConfirmationFetchingTitle
        case .emailNotConfirmedYet:
            return L10n.Localizable.darkWebMonitoringOnboardingEmailConfirmationFailureTitle
        case .breachesFound:
            return L10n.Localizable.darkWebMonitoringOnboardingEmailConfirmationConfirmedTitle
        case .breachesNotFound:
            return L10n.Localizable.darkWebMonitoringOnboardingEmailConfirmationNoBreachesTitle
        }
    }

    var subtitle: String {
        switch self {
        case .fetchingEmailConfirmationStatus:
            return ""
        case .emailNotConfirmedYet:
            return ""
        case .breachesFound:
            return L10n.Localizable.darkWebMonitoringOnboardingEmailConfirmationConfirmedSubtitle
        case .breachesNotFound:
            return L10n.Localizable.darkWebMonitoringOnboardingEmailConfirmationNoBreachesSubtitle
        }
    }
}

struct DWMEmailConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(deviceRange: .some([.iPhoneSE]), dynamicTypePreview: true) {
            DWMEmailConfirmationView(viewModel: .mock(state: .fetchingEmailConfirmationStatus), transitionHandler: nil, action: { _ in })
            DWMEmailConfirmationView(viewModel: .mock(state: .emailNotConfirmedYet), transitionHandler: nil, action: { _ in })
            DWMEmailConfirmationView(viewModel: .mock(state: .breachesFound), transitionHandler: nil, action: { _ in })
            DWMEmailConfirmationView(viewModel: .mock(state: .breachesNotFound), transitionHandler: nil, action: { _ in })
        }
    }
}
