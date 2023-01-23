import SwiftUI
import UIDelight

struct HelpCenterSettingsView: View {

    @StateObject
    var viewModel: HelpCenterSettingsViewModel

    init(viewModel: @autoclosure @escaping () -> HelpCenterSettingsViewModel) {
        _viewModel = .init(wrappedValue: viewModel())
    }

    var body: some View {
        List {
            Section(header: Text(L10n.Localizable.kwHelpCenter)) {
                Button(action: viewModel.openHowToGuide) {
                    Text(L10n.Localizable.helpCenterGetStartedTitle)
                        .foregroundColor(.primary)
                }
                Button(action: viewModel.openTroubleshooting) {
                    Text(L10n.Localizable.helpCenterHavingTroubleTitle)
                        .foregroundColor(.primary)
                }
                Button(action: viewModel.openDeleteAccount) {
                    Text(L10n.Localizable.helpCenterDeleteAccountTitle)
                        .foregroundColor(.primary)
                }
            }
            Section(header: Text(L10n.Localizable.settingsHelpLegalSection)) {
                Button(action: viewModel.openPrivacyPolicy) {
                    Text(L10n.Localizable.kwCreateAccountPrivacy)
                        .foregroundColor(.primary)
                }
                Button(action: viewModel.openTermsOfService) {
                    Text(L10n.Localizable.kwCreateAccountTermsConditions)
                        .foregroundColor(.primary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(Text(L10n.Localizable.helpCenterTitle))
        .navigationBarTitleDisplayMode(.inline)
        .reportPageAppearance(.help)
        .hideTabBar()
    }
}

struct HelpCenterSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        HelpCenterSettingsView(viewModel: HelpCenterSettingsViewModel(usageLogService: UsageLogService.fakeService))
    }
}
