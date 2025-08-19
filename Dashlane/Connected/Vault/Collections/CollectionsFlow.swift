import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI
import UIDelight
import VaultKit

public struct CollectionsFlow: View {
  @StateObject
  var viewModel: CollectionsFlowViewModel

  @Environment(\.toast)
  var toast

  init(viewModel: @autoclosure @escaping () -> CollectionsFlowViewModel) {
    self._viewModel = .init(wrappedValue: viewModel())
  }

  public var body: some View {
    StepBasedContentNavigationView(steps: $viewModel.steps) { step in
      switch step {
      case .list:
        CollectionsListView(viewModel: viewModel.collectionsListViewModelFactory.make()) {
          viewModel.handleCollectionsListAction($0)
        }
      case .collectionDetail(let collection):
        CollectionDetailView(
          viewModel: viewModel.collectionDetailViewModelFactory.make(collection: collection)
        ) { viewModel.handleCollectionDetailAction($0) }
      case .itemDetail(let item):
        VaultDetailView(model: viewModel.makeDetailViewModel(), itemDetailViewType: .viewing(item))
      }
    }
    .alert(
      CoreL10n.KWVaultItem.Collections.AttachmentsLimitation.Message.share,
      isPresented: $viewModel.showCannotShareWithAttachments
    ) {
      Button(CoreL10n.kwButtonClose, role: .cancel) {

      }
    }
    .sheet(item: $viewModel.collectionToShare) { collection in
      CollectionShareFlowView(model: viewModel.makeCollectionShareFlowViewModel(for: collection))
    }
    .sheet(item: $viewModel.collectionAccessToChange) { collection in
      NavigationView {
        SharingCollectionMembersDetailView(
          model: viewModel.makeSharingCollectionMembersViewModel(for: collection)
        ) {
          viewModel.handleSharingCollectionMembersDetailAction($0, with: toast)
        }
      }
    }
  }
}

struct CollectionsFlow_Previews: PreviewProvider {
  static var previews: some View {
    CollectionsFlow(viewModel: .mock)
  }
}
