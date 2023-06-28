import SwiftUI
import CorePersonalData
import UIDelight
import UIComponents
import DesignSystem
import VaultKit
import CoreLocalization

struct BreachDetailView<Model: BreachDetailViewModelProtocol>: View {

    @ObservedObject
    var model: Model

    var successState: Bool {
        return model.currentConfiguration == .itemSaved
    }

    var body: some View {
        FullScreenScrollView {
            VStack(alignment: .leading, spacing: 1) {
                BreachTextField(title: L10n.Localizable.dwmOnboardingFixBreachesDetailName, text: $model.title)
                    .opacity(model.currentConfiguration == .newPasswordToBeSaved ? 0.2 : 1)
                    .disabled(model.currentConfiguration == .newPasswordToBeSaved || model.currentConfiguration == .itemSaved)

                BreachTextField(title: L10n.Localizable.dwmOnboardingFixBreachesDetailEmail, text: $model.email)
                    .textContentType(.emailAddress)
                    .opacity(model.currentConfiguration == .newPasswordToBeSaved ? 0.2 : 1)
                    .disabled(model.currentConfiguration == .newPasswordToBeSaved || model.currentConfiguration == .itemSaved)

                BreachPasswordField(title: L10n.Localizable.dwmOnboardingFixBreachesDetailPassword, text: $model.password, shouldReveal: $model.shouldRevealPassword, isFocused: $model.isPasswordFieldFocused)
                    .disabled(model.currentConfiguration == .itemSaved)

                infobox

                BreachTextField(title: L10n.Localizable.dwmOnboardingFixBreachesDetailWebsite, text: $model.website)
                    .opacity(model.currentConfiguration == .newPasswordToBeSaved ? 0.2 : 1)
                    .disabled(model.currentConfiguration == .newPasswordToBeSaved || model.currentConfiguration == .itemSaved)

                Spacer()
            }
        }
        .animation(.easeOut(duration: 0.5), value: model.currentConfiguration)
        .navigationTitle(L10n.Localizable.dwmOnboardingFixBreachesDetailNavigationTitle)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                cancelButton
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                saveButton
            }
        }
        .navigationBarBackButtonHidden(true)
        .backgroundColorIgnoringSafeArea(.ds.background.default)
        .sheet(isPresented: $model.shouldShowMiniBrowser) {
            self.miniBrowser
        }
    }

    private var cancelButton: some View {
        let title = successState ? L10n.Localizable.dwmOnboardingFixBreachesMainBack : L10n.Localizable.dwmOnboardingFixBreachesDetailCancel
        return NavigationBarButton(title, action: model.cancel)
    }

    private var saveButton: some View {
        let title = successState ? CoreLocalization.L10n.Core.kwDoneButton : L10n.Localizable.dwmOnboardingFixBreachesDetailSave

        return NavigationBarButton(action: model.save, label: {
            Text(title)
        })
            .opacity(model.canSave ? 1 : 0.5)
    }

    private var miniBrowser: some View {
        if let model = model.miniBrowserViewModel {
            return NavigationView {
                MiniBrowser(model: model)
            }.eraseToAnyView()
        } else {
            return EmptyView().eraseToAnyView()
        }
    }

    @ViewBuilder
    private var infobox: some View {
        let title = infoboxTitle(for: model.currentConfiguration)
        let description = infoboxDescription(for: model.currentConfiguration)

        Infobox(title: title ?? description,
                description: title != nil ? infoboxDescription(for: model.currentConfiguration) : nil) {
            if let primaryButtonTitle = infoboxPrimaryButtonTitle(for: model.currentConfiguration) {
                Button(action: model.changePassword, title: primaryButtonTitle)
            }
            if let secondaryButtonTitle = infoboxSecondaryButtonTitle(for: model.currentConfiguration) {
                Button(action: model.newPasswordToBeSaved, title: secondaryButtonTitle)
            }
        }
        .style(mood: infoboxMood(for: model.currentConfiguration))
        .padding(8)
    }

    private func infoboxMood(for breachDetailViewConfiguration: BreachDetailViewConfiguration) -> Mood {
        switch breachDetailViewConfiguration {
        case .itemSaved:
            return .positive
        default:
            return .brand
        }
    }

    private func infoboxTitle(for breachDetailViewConfiguration: BreachDetailViewConfiguration) -> String? {
        switch breachDetailViewConfiguration {
        case .passwordFound:
            return L10n.Localizable.dwmOnboardingFixBreachesDetailPasswordCompromisedTitle
        case .passwordNotFound(let eventDate):
            let formattedDate = eventDate.flatMap { $0.formatted(date: .abbreviated, time: .omitted) }
            return formattedDate.flatMap(L10n.Localizable.dwmOnboardingFixBreachesDetailMessageNoPasswordTitle) ?? L10n.Localizable.dwmOnboardingFixBreachesDetailMessageNoPasswordNoDateTitle
        case .newPasswordToBeSaved:
            return L10n.Localizable.dwmOnboardingFixBreachesDetailLetsSaveTitle
        case .itemSaved:
            return L10n.Localizable.dwmOnboardingFixBreachesDetailSecuredTitle
        }
    }

    private func infoboxDescription(for breachDetailViewConfiguration: BreachDetailViewConfiguration) -> String {
        switch breachDetailViewConfiguration {
        case .passwordFound:
            return L10n.Localizable.dwmOnboardingFixBreachesDetailPasswordCompromisedDescription
        case .passwordNotFound:
            return L10n.Localizable.dwmOnboardingFixBreachesDetailMessageNoPasswordDescription
        case .newPasswordToBeSaved:
            return L10n.Localizable.dwmOnboardingFixBreachesDetailLetsSaveDescription
        case .itemSaved:
            return L10n.Localizable.dwmOnboardingFixBreachesDetailSecuredDescription
        }
    }

    private func infoboxPrimaryButtonTitle(for breachDetailViewConfiguration: BreachDetailViewConfiguration) -> String? {
        switch breachDetailViewConfiguration {
        case .passwordFound:
            return L10n.Localizable.dwmOnboardingFixBreachesDetailPasswordCompromisedChangeNow
        case .passwordNotFound:
            return L10n.Localizable.dwmOnboardingFixBreachesDetailPasswordCompromisedChangeNow
        default:
            return nil
        }
    }

    private func infoboxSecondaryButtonTitle(for breachDetailViewConfiguration: BreachDetailViewConfiguration) -> String? {
        switch breachDetailViewConfiguration {
        case .passwordFound:
            return L10n.Localizable.dwmOnboardingFixBreachesDetailPasswordCompromisedDone
        case .passwordNotFound:
            return L10n.Localizable.dwmOnboardingFixBreachesDetailPasswordCompromisedDone
        default:
            return nil
        }
    }
}

struct BreachDetailView_Previews: PreviewProvider {

    class FakeModel: BreachDetailViewModelProtocol {
        var shouldShowMiniBrowser: Bool = false
        var title: String = "linkedin.com"
        var email: String = "_"
        var password: String
        var shouldRevealPassword: Bool = false
        var isPasswordFieldFocused: Bool = false
        var website: String = "_"
        var currentConfiguration: BreachDetailViewConfiguration = .passwordNotFound(eventDate: Date.now)
        var canSave: Bool = false
        var miniBrowserViewModel: MiniBrowserViewModel? = .mock(url: URL(string: "_")!,
                                                                domain: "linkedin.com")

        init(password: String) {
            self.password = password
        }

        func cancel() {}
        func save() {}
        func changePassword() {}
        func newPasswordToBeSaved() {}
    }

    static var previews: some View {
        MultiContextPreview {
            NavigationView {
                BreachDetailView(model: FakeModel(password: "123"))
            }
        }
    }
}
