import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI
import UIComponents
import VaultKit

struct PasswordHealthView: View {

  enum Action {
    case addPasswords
    case detailedList(PasswordHealthKind)
    case credentialDetail(Credential)
  }

  @StateObject
  var viewModel: PasswordHealthViewModel

  var action: (Action) -> Void

  init(
    viewModel: @escaping @autoclosure () -> PasswordHealthViewModel,
    action: @escaping (Action) -> Void
  ) {
    self._viewModel = .init(wrappedValue: viewModel())
    self.action = action
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 0) {
        PasswordHealthSummaryView(viewModel: viewModel, action: action)

        if !viewModel.isFrozen {
          ForEach(viewModel.summaryListViewModels, id: \.kind) { viewModel in
            PasswordHealthListView(
              viewModel: viewModel,
              action: action
            )
          }
        } else {
          Infobox(
            CoreLocalization.L10n.Core.frozenAccountTitle,
            description: CoreLocalization.L10n.Core.frozenAccountMessage
          ) {
            Button(CoreLocalization.L10n.Core.frozenAccountAction) {
              viewModel.displayPaywall()
            }
          }
          .style(mood: .danger)
          .padding(.top, 16)
        }
      }
      .padding(.horizontal, 16)
      .padding(.bottom, 16)
    }
    .backgroundColorIgnoringSafeArea(.ds.background.alternate)
    .navigationTitle(L10n.Localizable.identityDashboardTitle)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        UserSpaceSwitcher(model: viewModel.userSpaceSwitcherViewModelFactory.make())
      }
    }
    .reportPageAppearance(.toolsPasswordHealthOverview)
  }
}

struct PasswordHealthView_Previews: PreviewProvider {
  static var previews: some View {
    PasswordHealthView(viewModel: .mock) { _ in }
  }
}
