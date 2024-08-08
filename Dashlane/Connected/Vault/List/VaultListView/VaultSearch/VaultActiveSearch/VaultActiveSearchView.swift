import CoreLocalization
import DesignSystem
import SwiftUI
import VaultKit

struct VaultActiveSearchView: View {
  @StateObject var model: VaultActiveSearchViewModel

  init(model: @autoclosure @escaping () -> VaultActiveSearchViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    ZStack {
      if !model.searchResult.searchCriteria.isEmpty {
        searchingView
      } else {
        recentSearches
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .animation(.linear(duration: 0.2), value: model.searchResult.searchCriteria)
    .reportPageAppearance(.search)
  }

  @ViewBuilder
  private var searchingView: some View {
    if !model.searchResult.hasResult() {
      if let category = model.activeFilter {
        ListPlaceholder(
          category: category,
          accessory: placeholderAddButton
        )
        .fiberAccessibilityAnnouncement(for: model.$searchResult) { _ in
          L10n.Localizable.accessibilityVaultSearchViewNoResult
        }
      } else {
        ListPlaceholder(
          icon: Image(asset: FiberAsset.emptySearch),
          text: CoreLocalization.L10n.Core.emptySearchResultsText,
          accessory: placeholderAddButton
        )
        .fiberAccessibilityAnnouncement(for: model.$searchResult) { _ in
          L10n.Localizable.accessibilityVaultSearchViewNoResult
        }
      }
    } else {
      searchResults
        .dismissKeyboardOnDrag()
        .id(model.searchResult.searchCriteria)
        .accessibility(label: Text(L10n.Localizable.itemsTabSearchPlaceholder))
        .fiberAccessibilityAnnouncement(for: model.$searchResult) {
          L10n.Localizable.accessibilityVaultSearchViewResultCount($0.count)
        }
    }
  }

  private var searchResults: some View {
    ItemsList(
      sections: model.searchResult.sections
    ) { configuration in
      ActionableVaultItemRow(
        model: model.makeRowViewModel(
          configuration.vaultItem,
          isSuggestedItem: configuration.isSuggestedItem,
          isInCollection: configuration.isInCollectionSection,
          origin: .search
        )
      ) {
        model.select(
          .init(
            item: configuration.vaultItem,
            origin: .searchResult,
            count: model.searchResult.count())
        )
      }
      .draggableItem(configuration.vaultItem)
      .highlightedValue(model.searchResult.searchCriteria)
      .vaultItemRowCollectionActions([.addToACollection, .removeFromACollection])
      .vaultItemRowEditAction(
        .init(isEnabled: configuration.vaultItem.canEditItem) {
          model.select(
            .init(
              item: configuration.vaultItem, origin: .searchResult,
              count: model.searchResult.count()),
            isEditing: true
          )
        })
    }
    .vaultItemsListDelete(.init(model.delete))
    .vaultItemsListDeleteBehaviour(.init(model.itemDeleteBehaviour))
  }

  private var recentSearches: some View {
    ItemsList(sections: model.recentSearchSections) { configuration in
      ActionableVaultItemRow(
        model: model.makeRowViewModel(
          configuration.vaultItem,
          isSuggestedItem: configuration.isSuggestedItem,
          origin: .search
        )
      ) {
        model.select(
          .init(
            item: configuration.vaultItem,
            origin: .searchResult,
            count: model.recentSearchSections.first?.items.count ?? 0)
        )
      }
      .draggableItem(configuration.vaultItem)
      .vaultItemRowCollectionActions([.addToACollection, .removeFromACollection])
      .vaultItemRowEditAction(
        .init(isEnabled: configuration.vaultItem.canEditItem) {
          model.select(
            .init(
              item: configuration.vaultItem,
              origin: .searchResult,
              count: model.recentSearchSections.first?.items.count ?? 0
            ),
            isEditing: true
          )
        }
      )
    }
    .dismissKeyboardOnDrag()
    .id(model.searchResult.searchCriteria)
    .accessibility(label: Text(L10n.Localizable.recentSearchTitle))
  }

  private var placeholderAddButton: AnyView {
    AddVaultButton(
      text: Text(L10n.Localizable.announceWelcomeM2DNoItemCta),
      category: model.activeFilter,
      onTap: model.onAddItemDropdown
    ) { model.add(type: $0) }
    .eraseToAnyView()
  }
}

struct VaultActiveSearchView_Previews: PreviewProvider {
  static var previews: some View {
    VaultActiveSearchView(model: .mock)
  }
}
