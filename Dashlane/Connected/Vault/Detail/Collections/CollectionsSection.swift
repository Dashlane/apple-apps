import CorePersonalData
import DashlaneAppKit
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight
import VaultKit

struct CollectionsSection<Item: VaultItem & Equatable>: View {

    @ObservedObject
    var model: CollectionsSectionModel<Item>

    @State
    private var showNewCollectionAddition: Bool = false

    @FocusState
    private var focusNewCollectionAddition

    @State
    private var newCollectionName: String = ""

    @ScaledMetric
    private var verticalRowSpacing: CGFloat = 8

    @ScaledMetric
    private var horizontalRowSpacing: CGFloat = 16

    private let collectionAdditionRowId = "CollectionAdditionRow"

    var body: some View {
        if model.mode.isEditing {
            editingCollectionsList
        } else {
            viewingCollectionsList
        }
    }
}

private extension CollectionsSection {
    var sectionTitle: String {
        model.collections.count > 1 ? L10n.Localizable.KWVaultItem.Collections.Title.plural : L10n.Localizable.KWVaultItem.Collections.Title.singular
    }
}

private extension CollectionsSection {
    var editingCollectionsList: some View {
        Section(sectionTitle) {
                                    ScrollViewReader { value in
                ForEach(model.collections) { collection in
                    collectionRow(collection)
                }
                .onChange(of: focusNewCollectionAddition) { newValue in
                    guard newValue else { return }
                    withAnimation(.easeInOut) {
                        value.scrollTo(collectionAdditionRowId, anchor: .top)
                    }
                }
                .onReceive(model.service.$mode) { _ in
                    hideNewCollectionAdditionRow()
                }

                if showNewCollectionAddition {
                    categoryAdditionRow
                }

                addAnotherCollection
            }
        }
    }

    func collectionRow(_ collection: VaultCollection) -> some View {
        VStack(alignment: .leading, spacing: verticalRowSpacing) {
            HStack(spacing: horizontalRowSpacing) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.ds.text.danger.quiet)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            model.removeItem(from: collection)
                        }
                    }

                Chip(collection.name)
            }

            Divider()
        }
        .padding(.bottom, verticalRowSpacing / 2)
        .frame(maxWidth: .infinity)
    }

    var addAnotherCollection: some View {
        HStack(spacing: horizontalRowSpacing) {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(.ds.text.positive.standard)
            Text(L10n.Localizable.KWVaultItem.Collections.addAnother)
                .foregroundColor(.ds.text.brand.standard)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, verticalRowSpacing / 2)
        .onTapGesture(perform: showNewCollectionAdditionRow)
    }

    var categoryAdditionRow: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: horizontalRowSpacing) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.ds.text.danger.quiet)
                    .onTapGesture(perform: hideNewCollectionAdditionRow)

                TextField(L10n.Localizable.KWVaultItem.Collections.add, text: $newCollectionName)
                    .submitLabel(.done)
                    .focused($focusNewCollectionAddition)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .onSubmit {
                        addToCollection(name: newCollectionName)
                    }
            }
            .padding(.top, verticalRowSpacing / 8)
            .padding(.bottom, verticalRowSpacing + verticalRowSpacing / 4)

            Divider()
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, verticalRowSpacing / 2)
        .id(collectionAdditionRowId) 
    }
}

private extension CollectionsSection {
    var viewingCollectionsList: some View {
        Section(sectionTitle) {
            if model.collections.isEmpty {
                Button(L10n.Localizable.KWVaultItem.Collections.add, action: switchToEditModeWithCollectionAddition)
                    .buttonStyle(DetailRowButtonStyle())
            } else {
                ChipsList(model.collections.map(\.name))
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            }
        }
    }
}

private extension CollectionsSection {
    func showNewCollectionAdditionRow() {
        withAnimation(.easeInOut) {
            showNewCollectionAddition = true
            focusNewCollectionAddition = true
        }
    }

    func hideNewCollectionAdditionRow() {
        withAnimation(.easeInOut) {
            showNewCollectionAddition = false
            focusNewCollectionAddition = false
            newCollectionName = ""
        }
    }

    func switchToEditModeWithCollectionAddition() {
        withAnimation(.easeInOut) {
            model.mode = .updating
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showNewCollectionAdditionRow()
            }
        }
    }

    func addToCollection(name: String) {
        defer {
            hideNewCollectionAdditionRow()
        }
        model.addItemToCollection(named: name)
    }
}
