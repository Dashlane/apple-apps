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

    @ObservedObject
    var viewModel: PasswordHealthViewModel

    var action: (Action) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                PasswordHealthSummaryView(viewModel: viewModel, action: action)

                ForEach(viewModel.summaryListViewModels, id: \.kind) { viewModel in
                    PasswordHealthListView(
                        viewModel: viewModel,
                        action: action
                    )
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
