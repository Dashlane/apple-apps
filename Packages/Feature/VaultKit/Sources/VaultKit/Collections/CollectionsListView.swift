import CoreLocalization
import CorePersonalData
import CoreUserTracking
import CoreFeature
import DesignSystem
import SwiftUI
import UIComponents

#if os(iOS)
public struct CollectionsListView: View {

    public enum Action {
        case selected(VaultCollection)
    }

    @StateObject
    private var viewModel: CollectionsListViewModel
    
    @FeatureState(.sharingCollectionMilestone1)
    private var isSharingCollectionMilestone1Enabled: Bool

    @Environment(\.toast)
    var toast
    
    private let action: (Action) -> Void

    @State
    private var showAddition: Bool = false

    @State
    private var showCollectionEdition: VaultCollection?

    @State
    private var showDelete: Bool = false
    @State
    private var itemToDelete: VaultCollection?

    public init(
        viewModel: @autoclosure @escaping () -> CollectionsListViewModel,
        action: @escaping (Action) -> Void = { _ in }
    ) {
        self._viewModel = .init(wrappedValue: viewModel())
        self.action = action
    }

    public var body: some View {
        content
            .backgroundColorIgnoringSafeArea(.ds.background.alternate)
            .navigationBarTitle(L10n.Core.KWVaultItem.Collections.toolsTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toasterOn()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(
                        action: {
                            showAddition = true
                        },
                        label: {
                            Image.ds.action.add.outlined
                                .foregroundColor(.ds.text.brand.standard)
                        }
                    )
                }
            }
            .sheet(isPresented: $showAddition) {
                CollectionNamingView(viewModel: viewModel.makeCollectionNamingViewModel()) { _ in showAddition = false }
            }
            .sheet(item: $showCollectionEdition) { collection in
                CollectionNamingView(viewModel: viewModel.makeCollectionNamingViewModel(for: collection)) { completion in
                    showCollectionEdition = nil
                }
            }
            .reportPageAppearance(.collectionList)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.collections.isEmpty {
            emptyState
        } else {
            list
        }
    }

    private var list: some View {
        List(viewModel.collections.sortedByName()) { collection in
            CollectionRow(viewModel: viewModel.collectionRowViewModelFactory.make(collection: collection))
                .onTapWithFeedback {
                    viewModel.reportCollectionSelection(collection)
                    action(.selected(collection))
                }
                .swipeActions(edge: .trailing) {
                    swipeActions(for: collection)
                }
        }
        .confirmationDialog(L10n.Core.KWVaultItem.Collections.DeleteAlert.title,
                            isPresented: $showDelete,
                            presenting: itemToDelete,
                            actions: { itemToDelete in
                                        Button(L10n.Core.kwDelete, role: .destructive) { viewModel.delete(itemToDelete, with: toast) }
                                        Button(L10n.Core.cancel, role: .cancel) { }
                            }
                            , message: { _ in
                                        Text(L10n.Core.KWVaultItem.Collections.DeleteAlert.message)
        })
        .scrollContentBackground(.hidden)
        .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
    }
    
    @ViewBuilder
    private func swipeActions(for collection: VaultCollection) -> some View {
                        if !collection.isShared {
            Button {
                itemToDelete = collection
                showDelete = true
            } label: {
                Label(L10n.Core.kwDelete, systemImage: "trash.fill")
                    .labelStyle(.titleAndIcon)
            }
            .tint(.ds.container.expressive.danger.catchy.idle)
        }
        
                        if !collection.isShared {
            Button {
                showCollectionEdition = collection
            } label: {
                Label(L10n.Core.kwEdit, systemImage: "square.and.pencil")
            }
            .tint(.ds.container.expressive.neutral.catchy.idle)
        }

                if isSharingCollectionMilestone1Enabled, !collection.belongsToSpace(id: "") {
            Button {
                            } label: {
                Label(L10n.Core.kwShare, systemImage: "arrowshape.turn.up.forward.fill")
                    .labelStyle(.titleAndIcon)
            }
            .tint(.ds.container.expressive.neutral.catchy.active)
        }
    }
    
    private var emptyState: some View {
        VStack {
            Image.ds.folder.outlined
                .resizable()
                .frame(width: 96, height: 96)
                .foregroundColor(.ds.text.neutral.quiet)

            Text(L10n.Core.KWVaultItem.Collections.List.EmptyState.message)
                .font(.body)
                .foregroundColor(.ds.text.neutral.quiet)
                .multilineTextAlignment(.center)

            DS.Button(L10n.Core.KWVaultItem.Collections.List.EmptyState.button, icon: .ds.action.add.outlined) {
                showAddition = true
            }
            .style(mood: .brand, intensity: .catchy)
            .padding(.vertical, 16)
        }
        .padding(.horizontal, 24)
    }
}

struct CollectionsListView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionsListView(viewModel: .mock)
    }
}
#endif
