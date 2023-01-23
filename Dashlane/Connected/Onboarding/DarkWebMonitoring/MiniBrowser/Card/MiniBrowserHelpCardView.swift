import SwiftUI
import UIDelight

struct MiniBrowserHelpCardView: View {

    @ObservedObject
    var model: MiniBrowserHelpCardViewModel

    public let emailAction: DetailFieldActionSheet.Action
    public let passwordAction: DetailFieldActionSheet.Action

    @State private var shouldRevealPassword = false

    let maxHeight: CGFloat

    init(model: MiniBrowserHelpCardViewModel, emailAction: DetailFieldActionSheet.Action, passwordAction: DetailFieldActionSheet.Action, maxHeight: CGFloat) {
        self.model = model
        self.emailAction = emailAction
        self.passwordAction = passwordAction
        self.maxHeight = maxHeight
    }

    private var showDetailedInstructionsButtonTitle: String {
        return model.shouldShowDetailedInstructions ? L10n.Localizable.dwmOnboardingCardWSIDHideDetailedInstructions : L10n.Localizable.dwmOnboardingCardWSIDShowDetailedInstructions
    }

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(L10n.Localizable.dwmOnboardingCardWSIDTabChangePwd)
                    .foregroundColor(Color.white)
                    .font(.headline)
                    .padding(.bottom, 4)

                Button(action: {
                    self.model.showHideInstructions()
                }, label: {
                    HStack {
                        Text(showDetailedInstructionsButtonTitle)
                            .font(.footnote)
                            .fontWeight(.semibold)
                        Image(systemName: "arrowtriangle.down.fill")
                            .resizable()
                            .frame(width: 8, height: 4, alignment: .center)
                    }.foregroundColor(Color(asset: FiberAsset.secondaryActionText))
                }).padding(.bottom, 16)

                VStack {
                    if model.shouldShowDetailedInstructions {
                        detailedInstructions
                    } else {
                        loginView
                    }
                }
            }
            .padding(24)
            .embedInScrollViewIfNeeded()
        }
        .frame(maxHeight: maxHeight)
        .background(Color(asset: FiberAsset.mainGreen))
    }

    private var detailedInstructions: some View {
        VStack(alignment: .leading) {
            MiniBrowserNumberedListField(number: 1, content: L10n.Localizable.dwmOnboardingCardWSIDListLogInDomain(model.domain),
                                         highlightedContent: model.domain)
            MiniBrowserNumberedListField(number: 2, content: L10n.Localizable.dwmOnboardingCardWSIDListAccountSettings)
            MiniBrowserNumberedListField(number: 3, content: L10n.Localizable.dwmOnboardingCardWSIDListGoBackToDashlane)
        }
    }

    private var loginView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.Localizable.dwmOnboardingCardWSIDLoginTitle)
                .fontWeight(Font.Weight.regular)
                .font(.footnote)
                .foregroundColor(Color(asset: FiberAsset.mainGreen))
                .padding(.leading, 16.0)
                .padding(.top, 16.0)

            BreachTextField(title: L10n.Localizable.kwEmailPlaceholder,
                            text: Binding.constant(model.email),
                            isUserInteractionEnabled: false)
                .actions([emailAction])
                .textContentType(.emailAddress)
                .fiberFieldType(.email)
                .padding(.trailing, 16.0)

            passwordView.padding(.bottom, 16)
        }
        .background(Color.white)
        .cornerRadius(4.0)
    }

    private var passwordView: some View {
        if !model.password.isEmpty {
            return BreachPasswordField(title: L10n.Localizable.dwmOnboardingFixBreachesDetailPassword,
                                text: Binding.constant(model.password),
                                shouldReveal: $shouldRevealPassword,
                                isUserInteractionEnabled: false)
                .actions([passwordAction])
                .fiberFieldType(.password)
                .padding(.trailing, 16.0)
                .eraseToAnyView()
        } else {
            return BreachStaticField(title: L10n.Localizable.dwmOnboardingCardWSIDTabMissingPwdTitle,
                                     text: L10n.Localizable.dwmOnboardingCardWSIDTabMissingPwdContent)
                .padding(.horizontal, 16.0)
                .eraseToAnyView()
        }
    }

}

struct MiniBrowserHelpCardView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(dynamicTypePreview: true) {
            VStack {
                MiniBrowserHelpCardView(model:
                    MiniBrowserHelpCardViewModel(email: "_",
                                             password: "MyPassword",
                                             domain: "pinterest.com",
                                             usageLogService: DWMLogService.fakeService),
                                        emailAction: .copy({_, _ in }),
                                        passwordAction: .copy({_, _ in }),
                                        maxHeight: 305)
            }
        }.previewLayout(.sizeThatFits)
    }
}
