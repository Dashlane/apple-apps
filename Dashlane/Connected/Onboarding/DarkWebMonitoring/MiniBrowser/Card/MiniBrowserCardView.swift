import SwiftUI
import Combine
import UIDelight
import DashlaneAppKit
import CoreSettings
import VaultKit
import CoreLocalization

struct MiniBrowserCardView: View {

    let model: MiniBrowserCardViewModel
    let maxHeight: CGFloat

    @Binding
    var collapsed: Bool

    @AutoReverseState(autoReverseInterval: 1.2)
    var staticHeaderMessage: String?

    @State
    private var selectedTabIndex = 0

    init(model: MiniBrowserCardViewModel, maxHeight: CGFloat, collapsed: Binding<Bool>) {
        self.model = model
        self.maxHeight = maxHeight
        self._collapsed = collapsed
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView
                .fixedSize(horizontal: false, vertical: true)

            if collapsed == false {
                VStack {
                    if selectedTabIndex == 0 {
                        helpCardView
                    } else if selectedTabIndex == 1 {
                        pwdGeneratorView
                    }
                }
                .transition(AnyTransition.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .background(Color(asset: FiberAsset.mainGreen))
        .colorScheme(.light)
    }

    private var helpCardView: some View {
        MiniBrowserHelpCardView(model: model.helpCardViewModel,
                                emailAction: .copy(copyEmail),
                                passwordAction: .copy(copyPassword),
                                maxHeight: maxHeight)
    }

    private var pwdGeneratorView: some View {
        MiniBrowserPasswordGeneratorCardView(model: model.passwordGeneratorViewModel,
                                             action: .copy(copyGeneratedPassword),
                                             maxHeight: maxHeight)
    }

    private var headerView: some View {
        CardTabHeader(
            selectedIndex: $selectedTabIndex,
            collapsed: $collapsed,
            staticMessage: staticHeaderMessage,
            tabElements: [
                MiniBrowserTabElement(title: L10n.Localizable.dwmOnboardingCardWSIDTabTitle),
                MiniBrowserTabElement(title: L10n.Localizable.dwmOnboardingCardPWGTabTitle)
        ])
    }

    private func copyEmail(_ value: String, _ fieldType: DetailFieldType) {
        withAnimation {
            collapsed = true
        }
        staticHeaderMessage = L10n.Localizable.dwmOnboardingCardWSIDTabEmailCopied
        model.copyEmail(email: value)
    }

    private func copyPassword(_ value: String, _ fieldType: DetailFieldType) {
        withAnimation {
            collapsed = true
        }
        staticHeaderMessage = CoreLocalization.L10n.Core.dwmOnboardingCardPWGTabEmailCopied
        model.copyPassword(password: value)
    }

    private func copyGeneratedPassword(_ value: String, _ fieldType: DetailFieldType) {
        withAnimation {
            collapsed = true
        }
        staticHeaderMessage = CoreLocalization.L10n.Core.dwmOnboardingCardPWGTabEmailCopied
        model.copyGeneratedPassword(password: value)
    }
}

struct MiniBrowserCardView_Previews: PreviewProvider {
    static var model: MiniBrowserCardViewModel {
        MiniBrowserCardViewModel(email: "_",
                                 password: "test",
                                 domain: "test.com",
                                 userSettings: UserSettings(internalStore: .mock())) {_ in}
    }

    static var previews: some View {
        MultiContextPreview(dynamicTypePreview: true) {
            VStack {
                Spacer()
                MiniBrowserCardView(model: model, maxHeight: 305, collapsed: .constant(false))
            }
        }
    }
}
