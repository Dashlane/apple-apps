import Foundation
import SwiftUI
import UIComponents
import DesignSystem
import UIDelight

struct OnboardingView: View {
    
    @Environment(\.dismiss)
    var dismiss

    let completion: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            TabView {
                pageView(for: AuthenticatorAsset.onboardingLogo,
                         title: L10n.Localizable.onboardingPage1Title,
                         message: L10n.Localizable.onboardingPage1Message)
                pageView(for: AuthenticatorAsset.onboardingPage2,
                         title: L10n.Localizable.onboardingPage2Title,
                         message: L10n.Localizable.onboardingPage2Message)
                pageView(for: AuthenticatorAsset.onboardingPage3,
                         title: L10n.Localizable.onboardingPage3Title,
                         message: L10n.Localizable.onboardingPage3Message)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            RoundedButton(L10n.Localizable.onboardingPageCta, action: { completion() })
                .roundedButtonLayout(.fill)
                .padding(.horizontal, 24)
        }
        .onAppear() {
            setup()
        }
        .backgroundColorIgnoringSafeArea(.ds.background.alternate)
        .navigationBarBackButtonHidden(true)
    }
    
    func setup() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .ds.container.expressive.neutral.catchy.idle
        UIPageControl.appearance().pageIndicatorTintColor = .ds.container.expressive.neutral.quiet.idle
    }
    
    func pageView(for image: ImageAsset, title: String, message: String) -> some View {
        ScrollView {
            VStack(spacing: 60) {
                Image(asset: image)
                    .padding(.top, 32)
                VStack(spacing: 16) {
                    Text(title)
                        .font(.authenticator(.mediumTitle))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.ds.text.neutral.catchy)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(message)
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .foregroundColor(.ds.text.neutral.standard)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.bottom, 48)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(dynamicTypePreview: true) {
            OnboardingView() { }
        }
    }
}
