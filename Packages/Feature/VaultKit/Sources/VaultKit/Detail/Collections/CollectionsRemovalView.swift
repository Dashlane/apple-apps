#if os(iOS)
import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI
import UIComponents

public struct CollectionsRemovalView: View {

    public enum Completion {
        case done([VaultCollection])
        case cancel
    }

    @State
    var collections: [VaultCollection]

    @State
    private var collectionsRemoved: [VaultCollection] = []

    @State
    private var showCancelConfirmationDialog: Bool = false

    let completion: (Completion) -> Void

    public init(
        collections: [VaultCollection],
        completion: @escaping (Completion) -> Void
    ) {
        self.collections = collections.sortedByName()
        self.completion = completion
    }

    public var body: some View {
        NavigationView {
            content
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(
                            action: {
                                if collectionsRemoved.isEmpty {
                                    completion(.cancel)
                                } else {
                                    showCancelConfirmationDialog = true
                                }
                            },
                            title: L10n.Core.cancel
                        )
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        if !collectionsRemoved.isEmpty {
                            Button(action: { completion(.done(collectionsRemoved)) }, title: L10n.Core.kwSave)
                        }
                    }
                }
                .backgroundColorIgnoringSafeArea(.ds.background.alternate)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(L10n.Core.KWVaultItem.Collections.Removal.title)
                .confirmationDialog(
                    L10n.Core.KWVaultItem.UnsavedChanges.title,
                    isPresented: $showCancelConfirmationDialog,
                    titleVisibility: .visible,
                    actions: {
                        Button(L10n.Core.KWVaultItem.UnsavedChanges.leave, role: .destructive) { completion(.cancel) }
                        Button(L10n.Core.KWVaultItem.UnsavedChanges.keepEditing, role: .cancel) { }
                    },
                    message: {
                        Text(L10n.Core.KWVaultItem.UnsavedChanges.message)
                    }
                )
        }
    }

    @ViewBuilder
    private var content: some View {
        if collections.isEmpty {
            emptyState
        } else {
            list
        }
    }

    private var emptyState: some View {
        VStack {
            Image.ds.folder.outlined
                .resizable()
                .frame(width: 96, height: 96)
                .foregroundColor(.ds.text.neutral.quiet)

            Text(L10n.Core.KWVaultItem.Collections.Removal.EmptyState.message)
                .font(.body)
                .foregroundColor(.ds.text.neutral.quiet)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
    }

    private var list: some View {
        List(collections) { collection in
            row(for: collection)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    private func row(for collection: VaultCollection) -> some View {
        HStack(spacing: 16) {
            Button(action: {
                withAnimation(.easeInOut) {
                    collections.removeAll(where: { collection.id == $0.id })
                    collectionsRemoved.append(collection)
                }
            }, label: {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.ds.text.danger.quiet)
            })
            .buttonStyle(.plain)

            Tag(collection.name)
        }
    }
}

struct CollectionsRemovalView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionsRemovalView(collections: [PersonalDataMock.Collections.business]) { _ in }
    }
}
#endif
