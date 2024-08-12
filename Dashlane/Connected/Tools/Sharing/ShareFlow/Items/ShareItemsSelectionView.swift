import CoreLocalization
import SwiftUI
import UIComponents
import UIDelight
import VaultKit

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
      .autocorrectionDisabled()
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
        item: item,
        userSpace: model.userSpacesService.configuration.displayedUserSpace(for: item),
        vaultIconViewModelFactory: model.vaultItemIconViewModelFactory
      )
      .vaultItemRowHideSharing()
    }.onTapWithFeedback {
      model.toggle(item)
    }
  }

  @ToolbarContentBuilder
  var toolbarContent: some ToolbarContent {
    ToolbarItem(placement: .navigationBarLeading) {
      Button(CoreLocalization.L10n.Core.cancel) {
        dismiss()
      }
    }

    ToolbarItem(placement: .navigationBarTrailing) {
      let selectedItemsCount = model.selectedItems.count
      let suffix = model.selectedItems.isEmpty ? "" : "(\(selectedItemsCount))"
      let a11yLabel =
        selectedItemsCount == 1
        ? L10n.Localizable.sharingItemSelected(selectedItemsCount)
        : L10n.Localizable.sharingItemsSelected(selectedItemsCount)
      Button(CoreLocalization.L10n.Core.kwNext + suffix) {
        model.complete()
      }
      .disabled(model.selectedItems.isEmpty)
      .accessibilityLabel(a11yLabel)
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
