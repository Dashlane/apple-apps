import CoreLocalization
import CorePersonalData
import CorePremium
import CoreTypes
import CoreUserTracking
import DesignSystem
import SwiftTreats
import SwiftUI
import UIComponents
import VaultKit

struct ContextMenuListView: View {
  @StateObject
  var model: ContextMenuListViewModel

  @Environment(\.isSearching)
  private var isSearching

  @Environment(\.openURL)
  private var openURL

  @CapabilityState(.secretManagement)
  var secretManagementStatus

  init(model: @autoclosure @escaping () -> ContextMenuListViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    switch model.state {
    case .loading:
      loadingPlaceholder
    case .ready:
      list
        .tint(.ds.accentColor)
        .safeAreaInset(edge: .top) {
          header
            .background(Color.ds.background.default, ignoresSafeAreaEdges: .top)
        }
        .navigationTitle(CoreL10n.contextMenuAutofillDashlaneVault)
        .toolbar {
          toolbar
        }
        .searchable(
          text: $model.searchCriteria,
          isPresented: $model.isSearchActive,
          placement: .navigationBarDrawer(displayMode: .always),
          prompt: L10n.Localizable.itemsTabSearchPlaceholder
        )
        .onChange(of: isSearching) { _, newValue in
          self.model.isSearchActive = newValue
        }
    }
  }

  @ViewBuilder
  var list: some View {
    if model.sections.isEmpty {
      ListPlaceholder(vaultListFilter: model.activeFilter) { itemType in
        openURL(model.deeplinkURL(for: itemType))
      }
    } else {
      ItemsList(sections: model.sections) { configuration in
        HStack {
          let userSpace = model.userSpacesService.configuration
            .displayedUserSpace(for: configuration.vaultItem)
          VaultItemRow(
            item: configuration.vaultItem,
            userSpace: userSpace,
            vaultIconViewModelFactory: model.vaultItemIconViewModelFactory
          )
          .highlightedValue(model.searchCriteria)

          Image.ds.caretRight.outlined
            .resizable()
            .frame(width: 20, height: 20, alignment: .trailing)
            .foregroundStyle(Color.ds.text.neutral.quiet)
        }
        .onTapWithFeedback {
          model.select(
            configuration.vaultItem,
            highlight: model.highlightForTrackingEvents(isSuggested: configuration.isSuggestedItem))
        }
      }
    }
  }

  private var loadingPlaceholder: some View {
    ProgressView()
      .progressViewStyle(.indeterminate)
      .controlSize(.large)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  @ToolbarContentBuilder
  var toolbar: some ToolbarContent {
    ToolbarItem(placement: .navigationBarLeading) {
      Button(CoreL10n.cancel) {
        model.cancel()
      }
    }
  }

  private var header: some View {
    VStack(spacing: 0) {
      if !Device.is(.pad, .mac, .vision) && !model.isSearchActive {
        FiltersView(activeFilter: $model.activeFilter, enabledFilters: enabledFilters)
      }
    }
    .accessibilitySortPriority(.header)
  }

  private var enabledFilters: [ItemCategory] {
    ItemCategory.allCases.lazy
      .filter { category in
        switch category {
        case .secrets:
          return secretManagementStatus.isAvailable
        case .secureNotes, .wifi:
          return false
        default:
          return true
        }
      }
  }

}

extension ListPlaceholder where Accessory == AddVaultButton<Text> {
  fileprivate init(vaultListFilter: ItemCategory?, action: @escaping (VaultItem.Type) -> Void) {
    let buttonLabel = vaultListFilter?.placeholderCTATitle ?? CoreL10n.emptyItemsListCTA
    let addButton = AddVaultButton(
      text: Text(buttonLabel),
      isImportEnabled: false,
      category: vaultListFilter,
      onAction: { event in
        if case let .add(type) = event {
          action(type)
        }
      }
    )

    if let category = vaultListFilter {
      self.init(category: category) {
        addButton
      }
    } else {
      self.init(
        icon: .ds.item.login.outlined,
        title: CoreL10n.emptyItemsListTitle,
        description: CoreL10n.emptyItemsListDescription
      ) {
        addButton
      }
    }
  }
}

#Preview {
  ContextMenuListView(model: .mock)
}
