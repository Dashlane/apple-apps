import CoreLocalization
import DesignSystem
import SwiftUI
import UIDelight
import VaultKit

public struct CollectionsFlow: TabFlow {

        let tag: Int = 0
    let id: UUID = .init()
    let title: String
    let tabBarImage: NavigationImageSet

    @StateObject
    var viewModel: CollectionsFlowViewModel

    init(viewModel: @autoclosure @escaping () -> CollectionsFlowViewModel) {
        self._viewModel = .init(wrappedValue: viewModel())
        self.title = CoreLocalization.L10n.Core.KWVaultItem.Collections.toolsTitle
        self.tabBarImage = .init(image: .ds.folder.outlined, selectedImage: .ds.folder.filled)
    }

    public var body: some View {
        StepBasedContentNavigationView(steps: $viewModel.steps) { step in
            switch step {
            case .list:
                CollectionsListView(viewModel: viewModel.collectionsListViewModelFactory.make()) { viewModel.handleCollectionsListAction($0) }
            case .collectionDetail(let collection):
                CollectionDetailView(viewModel: viewModel.collectionDetailViewModelFactory.make(collection: collection)) { viewModel.handleCollectionDetailAction($0) }
            case .itemDetail(let item):
                viewModel.detailViewFactory.make(itemDetailViewType: .viewing(item))
                    .navigationBarHidden(true) 
            }
        }
        .resetTabBarItemTitle(L10n.Localizable.toolsTitle)
    }
}

struct CollectionsFlow_Previews: PreviewProvider {
    static var previews: some View {
        CollectionsFlow(viewModel: .mock)
    }
}
