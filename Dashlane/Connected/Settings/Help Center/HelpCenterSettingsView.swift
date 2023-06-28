import SwiftUI
import DesignSystem
import UIDelight
import CoreLocalization

struct HelpCenterSettingsView: View {

    @StateObject
    var viewModel: HelpCenterSettingsViewModel

    init(viewModel: @autoclosure @escaping () -> HelpCenterSettingsViewModel) {
        _viewModel = .init(wrappedValue: viewModel())
    }

    var body: some View {
        List {
            Section(header: Text(L10n.Localizable.kwHelpCenter).textStyle(.title.supporting.small)) {
                Button(action: viewModel.openHowToGuide) {
                    Text(L10n.Localizable.helpCenterGetStartedTitle)
                        .foregroundColor(.ds.text.neutral.standard)
                        .textStyle(.body.standard.regular)
                }
                Button(action: viewModel.openTroubleshooting) {
                    Text(L10n.Localizable.helpCenterHavingTroubleTitle)
                        .foregroundColor(.ds.text.neutral.standard)
                        .textStyle(.body.standard.regular)
                }
                Button(action: viewModel.openDeleteAccount) {
                    Text(L10n.Localizable.helpCenterDeleteAccountTitle)
                        .foregroundColor(.ds.text.neutral.standard)
                        .textStyle(.body.standard.regular)
                }
            }
            Section(header: Text(L10n.Localizable.settingsHelpLegalSection).textStyle(.title.supporting.small)) {
                Button(action: viewModel.openPrivacyPolicy) {
                    Text(CoreLocalization.L10n.Core.kwCreateAccountPrivacy)
                        .foregroundColor(.ds.text.neutral.standard)
                        .textStyle(.body.standard.regular)
                }
                Button(action: viewModel.openTermsOfService) {
                    Text(CoreLocalization.L10n.Core.kwCreateAccountTermsConditions)
                        .foregroundColor(.ds.text.neutral.standard)
                        .textStyle(.body.standard.regular)
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
        HelpCenterSettingsView(viewModel: HelpCenterSettingsViewModel())
    }
}
