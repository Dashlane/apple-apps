import CoreLocalization
import DesignSystem
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
      Section(header: Text(L10n.Localizable.kwHelpCenter).textStyle(.title.supporting.small)) {
        Button(action: viewModel.openHowToGuide) {
          Text(L10n.Localizable.helpCenterGetStartedTitle)
            .foregroundStyle(Color.ds.text.neutral.standard)
            .textStyle(.body.standard.regular)
        }
        Button(action: viewModel.openTroubleshooting) {
          Text(L10n.Localizable.helpCenterHavingTroubleTitle)
            .foregroundStyle(Color.ds.text.neutral.standard)
            .textStyle(.body.standard.regular)
        }
        Button(action: viewModel.openDeleteAccount) {
          Text(L10n.Localizable.helpCenterDeleteAccountTitle)
            .foregroundStyle(Color.ds.text.neutral.standard)
            .textStyle(.body.standard.regular)
        }
      }
      .listRowBackground(Color.ds.container.agnostic.neutral.supershy)

      Section(
        header: Text(L10n.Localizable.settingsHelpLegalSection).textStyle(.title.supporting.small)
      ) {
        Button(action: viewModel.openPrivacyPolicy) {
          Text(CoreL10n.kwCreateAccountPrivacy)
            .foregroundStyle(Color.ds.text.neutral.standard)
            .textStyle(.body.standard.regular)
        }
        Button(action: viewModel.openTermsOfService) {
          Text(CoreL10n.kwCreateAccountTermsConditions)
            .foregroundStyle(Color.ds.text.neutral.standard)
            .textStyle(.body.standard.regular)
        }
      }
      .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
    }
    .listStyle(.ds.insetGrouped)
    .navigationTitle(Text(L10n.Localizable.helpCenterTitle))
    .navigationBarTitleDisplayMode(.inline)
    .reportPageAppearance(.help)
    .toolbar(.hidden, for: .tabBar)
  }
}

struct HelpCenterSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    HelpCenterSettingsView(viewModel: HelpCenterSettingsViewModel())
  }
}
