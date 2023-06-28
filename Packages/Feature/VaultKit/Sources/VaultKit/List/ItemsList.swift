import CoreSharing
import SwiftUI
import UIComponents
import DesignSystem

public struct ItemRowViewConfiguration {
    public let vaultItem: VaultItem
    public let isSuggestedItem: Bool
    public let isInCollectionSection: Bool
}

public struct ItemsList<RowView: View>: View {

    @Environment(\.vaultItemsListHeaderView)
    var headerView

    @Environment(\.vaultItemsListFloatingHeaderView)
    var floatingHeaderView

    @Environment(\.vaultItemsListDelete)
    var delete

    @Environment(\.vaultItemsListDeleteBehaviour)
    var deleteBehaviour

    let sections: [DataSection]
    let rowProvider: (ItemRowViewConfiguration) -> RowView

    @State
    var deleteRequest: DeleteVaultItemRequest = .init()

    @State
    var itemToDelete: VaultItem?

    @State
    private var floatingHeaderViewHeight: CGFloat = 0

    private var sectionIndexesPadding: CGFloat {
        sections.count > 1 ? 10 : 0
    }

    public init(sections: [DataSection], rowProvider: @escaping (ItemRowViewConfiguration) -> RowView) {
        self.sections = sections
        self.rowProvider = rowProvider
    }

    public var body: some View {
        list
            .deleteItemAlert(request: $deleteRequest, deleteAction: deleteItem)
            .eraseToAnyView()
    }

        @ViewBuilder
    var list: some View {
        List {
            Section {
                headerView
                .accessibilitySortPriority(.header)

                                VaultForEach(
                    sections: sections,
                    delete: delete != nil ? { deleteRow(at: $0, section: $1) } : nil,
                    header: { section in
                        if section.isSuggestedItems {
                            sectionHeader(for: section)
                        } else {
                            sectionHeader(for: section)
                                .id(section.listIndex)
                        }
                    }, row: { section, item in
                        row(
                            for: item,
                            isSuggestedItem: section.isSuggestedItems,
                            isInCollectionSection: section.collectionName != nil
                        )
                    }
                ).accessibilitySortPriority(.list)
            }
            .disableHeaderCapitalization()
        }
        .listStyle(.plain)
        .padding(.top, floatingHeaderViewHeight)
        .overlay(alignment: .top) {
            topOverlay
        }
    }

        private var topOverlay: some View {
        floatingHeaderView?
            .background(heightGetterView)
            .accessibilitySortPriority(.header)
    }

    private var heightGetterView: some View {
        Rectangle()
            .foregroundColor(.clear)
            .onSizeChange { size in
                floatingHeaderViewHeight = size.height
            }
    }

        @ViewBuilder
    private func sectionHeader(for section: DataSection) -> some View {
        HStack(spacing: 6) {
            if !section.name.isEmpty {
                Text(section.name)
                    .font(.headline)
                    .foregroundColor(.ds.text.neutral.quiet)
                    .accessibilityLabel(section.name.lowercased())
            }

            #if os(iOS)
            if let collectionName = section.collectionName, !collectionName.isEmpty {
                Tag(collectionName)
            }
            #endif
        }
        .padding(.leading, 16)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowBackground(Color.ds.background.default)
    }

    private func row(for item: VaultItem, isSuggestedItem: Bool, isInCollectionSection: Bool) -> some View {
        rowProvider(.init(vaultItem: item, isSuggestedItem: isSuggestedItem, isInCollectionSection: isInCollectionSection))
            .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 10))
            .listRowBackground(Color.ds.background.default)
            .padding(.trailing, sectionIndexesPadding)
    }

        private func deleteRow(at indexSet: IndexSet, section: DataSection) {
        let items = indexSet.map {
            section.items[$0]
        }
        guard let item = items.first else {
            return
        }
        Task {
           try await delete(item)
        }
    }

    private func delete(_ item: VaultItem) async throws {
        itemToDelete = item
        deleteRequest.itemDeleteBehavior = try await deleteBehaviour(item)
        deleteRequest.isPresented = true
    }

    private func deleteItem() {
        guard let item = itemToDelete else {
            return
        }
        self.delete?(item)
        itemToDelete = nil
    }

    private func itemDeleteBehavior() async throws -> ItemDeleteBehaviour {
        guard let item = itemToDelete else {
            return .normal
        }
        return try await deleteBehaviour(item)
    }
}
