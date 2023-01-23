import Foundation
import SwiftTreats
import SwiftUI

struct HomeFlow: View {

    @StateObject
    var viewModel: HomeFlowViewModel

    init(viewModel: @autoclosure @escaping () -> HomeFlowViewModel) {
        self._viewModel = .init(wrappedValue: viewModel())
    }

    var body: some View {
        currentFlow
            .sheet(item: $viewModel.genericSheet) { sheet in
                sheet.view
            }
            .fullScreenCover(item: $viewModel.genericFullCover) { cover in
                cover.view
            }
    }

    @ViewBuilder
    var currentFlow: some View {
        switch viewModel.currentScreen {
        case .onboardingChecklist(let model):
            OnboardingChecklistFlow(viewModel: model)
        case .homeView(let model):
            vaultFlow(model)
        default:
            EmptyView()
        }
    }

    private func vaultFlow(_ model: VaultFlowViewModel) -> some View {
        NavigationView {
            VaultFlow(viewModel: model)
        }
        .navigationViewStyle(.stack)
        .transition(.opacity)
    }
}
