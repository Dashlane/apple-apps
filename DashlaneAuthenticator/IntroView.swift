import SwiftUI
import UIDelight
import DesignSystem

struct IntroView: View {

    enum Completion {
        case skip
        case add
    }
    
    let isStandAlone: Bool
    let completion: (Completion) -> Void

    @State
    var showOnboarding = false
    
    enum Steps {
        case onboardingPage
        case noTokens
    }
    var body: some View {
        NavigationView {
            ScrollView {
                mainView
            }
            .backgroundColorIgnoringSafeArea(.ds.background.alternate)
            .navigationBarStyle(.transparent)
            .hiddenNavigationTitle()
            .overlay(overlayButton, alignment: .bottom)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    var mainView: some View {
        VStack {
            VStack(spacing: 48) {
                Image(asset: AuthenticatorAsset.introIllustration)
                    .resizable()
                    .scaledToFit()
                VStack {
                    Text(L10n.Localizable.introTitle)
                    Text("Dashlane Authenticator")
                }
                .font(.authenticator(.largeTitle))
                .multilineTextAlignment(.center)
                .fiberAccessibilityElement(children: .combine)
            }.padding(.bottom, 40)
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
    
    var overlayButton: some View {
        RoundedButton(L10n.Localizable.introButtonTitle) {
            if isStandAlone {
                showOnboarding = true
            } else {
                completion(.add)
            }
        }
        .roundedButtonLayout(.fill)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .navigation(isActive: $showOnboarding, destination: {
           onboardingView
        })
    }
    
    var onboardingView: some View {
        OnboardingView() { completion(.add) }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    completion(.skip)
                    showOnboarding = false
                }, label: {
                    Text(L10n.Localizable.buttonTitleSkip)
                })
            }
        }
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(dynamicTypePreview: true) {
            NavigationView {
                IntroView(isStandAlone: true) {_ in }
                    .navigationBarStyle(.transparent)
            }
            NavigationView {
                IntroView(isStandAlone: false) {_ in }
                    .navigationBarStyle(.transparent)
            }
        }
    }
}
