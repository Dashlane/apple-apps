import SwiftUI
import UIDelight
import DesignSystem
import VaultKit
import CoreLocalization

struct PasswordGeneratorToolsFlow: TabFlow {
        let tabBarImage = NavigationImageSet(image: .ds.feature.passwordGenerator.outlined,
                                         selectedImage: .ds.feature.passwordGenerator.filled)
    let title: String = CoreLocalization.L10n.Core.tabGeneratorTitle
    let tag: Int = ConnectedCoordinator.Tab.passwordGenerator.tabBarIndexValue
    let id = UUID()
    let embedInNavigationView: Bool

    @StateObject
    var viewModel: PasswordGeneratorToolsFlowViewModel

    init(embedInNavigationView: Bool = false,
         viewModel: @autoclosure @escaping () -> PasswordGeneratorToolsFlowViewModel) {
        _viewModel = .init(wrappedValue: viewModel())
        self.embedInNavigationView = embedInNavigationView
    }

    var body: some View {
        StepBasedContentNavigationView(steps: $viewModel.steps) { step in
            switch step {
            case .root:
                PasswordGeneratorView(viewModel: viewModel.makePasswordGeneratorViewModel())
                    .onReceive(viewModel.deepLinkShowPasswordHistoryPublisher) { _ in
                        viewModel.showHistory()
                    }
            case .history:
                PasswordGeneratorHistoryView(model: viewModel.passwordGeneratorHistoryViewModelFactory.make())
            }
        }
        .embedInNavigationView(embedInNavigationView)
    }
}

struct PasswordGeneratorToolsFlow_Previews: PreviewProvider {
    static var previews: some View {
        PasswordGeneratorToolsFlow(viewModel: .mock)
    }
}
