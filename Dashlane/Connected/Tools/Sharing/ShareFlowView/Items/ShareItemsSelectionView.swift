import SwiftUI
import VaultKit
import UIDelight
import UIComponents

struct ShareItemsSelectionView: View {
    @StateObject
    var model: ShareItemsSelectionViewModel

    @Environment(\.dismiss)
    var dismiss

    init(model: @escaping @autoclosure () -> ShareItemsSelectionViewModel) {
        self._model = .init(wrappedValue: model())
    }

    var body: some View {
        ItemsList(sections: model.sections, rowProvider: rowView)
            .indexed()
            .searchable(text: $model.search)
            .navigationTitle(L10n.Localizable.kwShareItem)
            .navigationBarTitleDisplayMode(.inline)
            .reportPageAppearance(.sharingCreateItem)
            .toolbar {
                toolbarContent
            }
    }

    private func rowView(for input: ItemRowViewConfiguration) -> some View {
        let item = input.vaultItem

        return SelectionRow(isSelected: model.isSelected(item)) {
            VaultItemRow(
                model: model.itemRowViewModelFactory.make(
                    configuration: .init(item: item, isSuggested: input.isSuggestedItem),
                    additionalConfiguration: .init(quickActionsEnabled: false, shouldShowSharingStatus: false)
                )
            )
        }.onTapWithFeedback {
            model.toggle(item)
        }
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(L10n.Localizable.cancel) {
                dismiss()
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            let suffix = model.selectedItems.isEmpty ? "" : "(\(model.selectedItems.count))"
            Button(L10n.Localizable.kwNext + suffix) {
                model.complete()
            }
            .disabled(model.selectedItems.isEmpty)
        }
    }
}

struct ShareItemsSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ShareItemsSelectionView(model: .mock())
        }
    }
}
