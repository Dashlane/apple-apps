import CoreLocalization
import CoreUserTracking
import CorePersonalData
import DesignSystem
import SwiftUI
import VaultKit

struct CollectionDetailView: View {

    public enum Action {
        case selected(VaultItem)
    }

    @ScaledMetric
    private var sharedIconSize: CGFloat = 12

    @StateObject
    private var viewModel: CollectionDetailViewModel

    private let action: (Action) -> Void

    @Environment(\.toast)
    var toast

    init(
        viewModel: @autoclosure @escaping () -> CollectionDetailViewModel,
        action: @escaping (Action) -> Void = { _ in }
    ) {
        self._viewModel = .init(wrappedValue: viewModel())
        self.action = action
    }

    var body: some View {
        content
            .backgroundColorIgnoringSafeArea(.ds.background.alternate)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text(viewModel.collection.name)
                            .fontWeight(.semibold)
                        if let space = viewModel.collectionSpace, viewModel.shouldShowSpace {
                            UserSpaceIcon(space: space, size: .small)
                                .equatable()
                        }
                        if viewModel.collection.isShared {
                            Image.ds.shared.outlined
                                .resizable()
                                .frame(width: sharedIconSize, height: sharedIconSize)
                                .foregroundColor(.ds.text.neutral.quiet)
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    CollectionQuickActionsMenuView(viewModel: viewModel.makeQuickActionsMenuViewModel())
                }
            }
            .reportPageAppearance(.collectionDetails)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.items.isEmpty {
            emptyState
        } else {
            list
        }
    }

    private var list: some View {
        List(viewModel.items, id: \.id) { item in
            VaultItemRow(model: viewModel.makeRowViewModel(item)) { action(.selected(item)) }
                .vaultItemRowCollectionActions(
                    viewModel.collection.isShared ? [] : [.removeFromThisCollection(.init { viewModel.remove(item, with: toast) })]
                )
        }
        .scrollContentBackground(.hidden)
        .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
    }

    private var emptyState: some View {
        VStack {
            Image.ds.folder.outlined
                .resizable()
                .frame(width: 96, height: 96)
                .foregroundColor(.ds.text.neutral.quiet)

            Text(CoreLocalization.L10n.Core.KWVaultItem.Collections.Detail.EmptyState.message)
                .font(.body)
                .foregroundColor(.ds.text.neutral.quiet)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
    }
}
