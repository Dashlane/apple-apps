import CoreLocalization
import DesignSystemExtra
import LoginKit
import SwiftUI
import UIDelight
import VaultKit

struct ShareItemsSelectionView: View {
  @StateObject
  var model: ShareItemsSelectionViewModel

  @Environment(\.dismiss)
  var dismiss

  @Environment(\.accessControl)
  var accessControl

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

    return NativeSelectionRow(isSelected: model.isSelected(item), spacing: 16) {
      VaultItemRow(
        item: item,
        userSpace: model.userSpacesService.configuration.displayedUserSpace(for: item),
        vaultIconViewModelFactory: model.vaultItemIconViewModelFactory
      )
      .vaultItemRowHideSharing()
    }.onTapWithFeedback {
      model.toggle(item)
    }
    .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
  }

  @ToolbarContentBuilder
  var toolbarContent: some ToolbarContent {
    ToolbarItem(placement: .navigationBarLeading) {
      Button(
        action: {
          dismiss()
        },
        label: {
          Text(CoreL10n.cancel)
            .foregroundStyle(Color.ds.text.brand.standard)
        })
    }

    ToolbarItem(placement: .navigationBarTrailing) {
      let selectedItemsCount = model.selectedItems.count
      let suffix = model.selectedItems.isEmpty ? "" : "(\(selectedItemsCount))"
      let a11yLabel =
        selectedItemsCount == 1
        ? L10n.Localizable.sharingItemSelected(selectedItemsCount)
        : L10n.Localizable.sharingItemsSelected(selectedItemsCount)

      Button(
        action: {
          accessControl.requestAccess(to: model.selectedItems.values) { access in
            guard access else {
              return
            }

            model.complete()
          }
        },
        label: {
          Text(CoreL10n.kwNext + suffix)
            .foregroundStyle(Color.ds.text.brand.standard)
        }
      )
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
