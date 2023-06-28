import Foundation
import SwiftTreats
import SwiftUI
import CoreLocalization

struct HomeFlow: TabFlow {
        let tag: Int = 0
    let id: UUID = .init()
    let tabBarImage = NavigationImageSet(
        image: .ds.home.outlined,
        selectedImage: .ds.home.filled
    )
    let title = CoreLocalization.L10n.Core.mainMenuHomePage

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
        #if os(macOS) || targetEnvironment(macCatalyst)
            .sheet(item: $viewModel.genericFullCover) { cover in
                NavigationView {
                    cover.view
                }
            }
        #else
            .fullScreenCover(item: $viewModel.genericFullCover) { cover in
                NavigationView {
                    cover.view
                }
            }
        #endif
            .onReceive(viewModel.deeplinkPublisher) { deeplink in
                switch deeplink {
                case let .search(searchCriteria):
                    self.viewModel.displaySearch(for: searchCriteria)
                case let .importMethod(importDeeplink):
                    self.viewModel.presentImport(for: importDeeplink)
                case let .vault(vaultDeeplink):
                    guard self.viewModel.canHandle(deepLink: vaultDeeplink) else { return }
                    self.viewModel.handle(vaultDeeplink)
                case let .prefilledCredential(password):
                    self.viewModel.createCredential(using: password)
                default: break
                }
            }
            .homeModalAnnouncements(model: viewModel.homeModalAnnouncementsViewModel)
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

    @ViewBuilder
    private func vaultFlow(_ model: VaultFlowViewModel) -> some View {
        if Device.isIpadOrMac {
            VaultFlow(viewModel: model)
        } else {
            NavigationView {
                VaultFlow(viewModel: model)
            }
            .navigationViewStyle(.stack)
            .transition(.opacity)
        }
    }
}
