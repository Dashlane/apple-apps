import SwiftUI
import Combine
import UIDelight
import LoginKit
import UIComponents
import DesignSystem

struct GuidedOnboardingPlanView: View {

    @State
    var showPlanReady: Bool = false

    private let transitionHandler: GuidedOnboardingTransitionHandler?

    init(transitionHandler: GuidedOnboardingTransitionHandler? = nil) {
        self.transitionHandler = transitionHandler
    }

    var body: some View {
        ZStack {
            loadingView()
            swipeToRevealView()
        }
        .background(.ds.background.default)
        .loginAppearance(backgroundColor: .ds.background.default)
        .onAppear(perform: fakeLoading)
        .onTapGesture {
            self.transitionHandler?.dismiss()
        }
        .gesture(
            DragGesture().onChanged({ value in
                self.transitionChanged(value: value)
            }).onEnded({ _ in
                self.transitionEnded()
            })
        )
    }

    func loadingView() -> some View {
        ZStack {
            VStack {
                LottieView(.logo, contentMode: .scaleAspectFill)
                    .colorMultiply(.ds.text.neutral.standard)
                    .frame(width: 240.0, height: 240.0)
                    .opacity(showPlanReady ? 0.0 : 1.0)
                    .hidden(showPlanReady)
                    .offset(y: showPlanReady ? -60.0 : -30.0)

                Text(L10n.Localizable.guidedOnboardingPlanReady)
                    .font(DashlaneFont.custom(26.0, .bold).font)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(showPlanReady ? 1.0 : 0.0)
            }
            .padding(EdgeInsets(top: 0.0, leading: 24.0, bottom: 0.0, trailing: 24.0))

            VStack {
                Text(L10n.Localizable.guidedOnboardingCreatingPlan)
                    .font(DashlaneFont.custom(26.0, .bold).font)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(EdgeInsets(top: 0.0, leading: 24.0, bottom: 0.0, trailing: 24.0))
            .offset(y: 80.0)
            .opacity(showPlanReady ? 0.0 : 1.0)
        }
    }

    func swipeToRevealView() -> some View {
        VStack {
            Spacer()
            HStack(spacing: 24.0) {
                Image.ds.caretUp.outlined
                    .colorMultiply(Color(asset: FiberAsset.pageControlSelected))
                    .accessibilityHidden(true)
                Text(L10n.Localizable.guidedOnboardingSwipeToReveal)
                    .font(.system(size: 17.0))
                    .foregroundColor(.ds.text.neutral.catchy)
                Image.ds.caretUp.outlined
                    .colorMultiply(Color(asset: FiberAsset.pageControlSelected))
                    .accessibilityHidden(true)
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isButton)
        }
        .padding(48.0)
        .offset(y: showPlanReady ? 0.0 : 48.0)
        .opacity(showPlanReady ? 1.0 : 0.0)
    }

    func fakeLoading() {
        withAnimation(Animation.spring().delay(1.8)) {
            self.showPlanReady = true
        }
    }

    private func transitionEnded() {
        transitionHandler?.update(state: .end)
    }

    private func transitionChanged(value: DragGesture.Value) {
        transitionHandler?.update(state: .changed(value))
    }
}

extension GuidedOnboardingPlanView: NavigationBarStyleProvider {
    var navigationBarStyle: UIComponents.NavigationBarStyle {
        return .hidden(statusBarStyle: .lightContent)
    }
}

struct GuidedOnboardingCreatingPlanView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(deviceRange: .some([.iPhoneSE, .iPhone11])) {
            NavigationView {
                GuidedOnboardingPlanView()
            }
        }
    }
}
