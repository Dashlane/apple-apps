import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI
import VaultKit

struct ExtensionSearchView<InactiveView: View, Placeholder: View>: View {
  @StateObject
  var model: ExtensionSearchViewModel

  @State
  var isSearching: Bool = false

  let select: (VaultItem, VaultSelectionOrigin) -> Void
  let placeholderAccessory: Placeholder
  let inactiveSearchView: InactiveView

  init(
    model: @escaping @autoclosure () -> ExtensionSearchViewModel,
    select: @escaping (VaultItem, VaultSelectionOrigin) -> Void,
    @ViewBuilder placeholderAccessory: () -> Placeholder,
    @ViewBuilder inactiveSearchView: () -> InactiveView
  ) {
    _model = .init(wrappedValue: model())
    self.select = select
    self.placeholderAccessory = placeholderAccessory()
    self.inactiveSearchView = inactiveSearchView()
  }

  var body: some View {
    ZStack {
      if isSearching {
        list
      } else {
        InactiveSearchContainer(
          isSearching: $isSearching,
          inactiveSearchView: { inactiveSearchView })
      }
    }
    .navigationBarBackButtonHidden(true)
    .searchable(
      text: $model.searchCriteria, prompt: L10n.Localizable.tachyonCredentialsListSearchPlaceholder
    )
    .autocorrectionDisabled()
    .background(Color.ds.background.default, ignoresSafeAreaEdges: .all)
    .edgesIgnoringSafeArea(.bottom)
    .frame(maxHeight: .infinity)
    .onChange(of: isSearching) { _, newValue in
      model.isActive = newValue
    }
  }

  private var list: some View {
    ZStack {
      if !model.result.searchCriteria.isEmpty {
        if !model.result.hasResult() {
          ListPlaceholder(
            icon: .ds.item.login.outlined,
            title: CoreL10n.emptyPasswordsListTitle,
            description: CoreL10n.emptyPasswordsListDescription
          ) {
            placeholderAccessory
          }
        } else {
          searchResults
            #if !os(visionOS)
              .scrollDismissesKeyboard(.immediately)
            #endif
            .id(model.result.searchCriteria)
        }
      } else {
        recentSearches
          #if !os(visionOS)
            .scrollDismissesKeyboard(.immediately)
          #endif
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .animation(.linear(duration: 0.2), value: model.result.searchCriteria)
  }

  private var recentSearches: some View {
    ListResultContainer(
      isSearching: $isSearching,
      sections: model.recentSearchItems,
      vaultItemIconViewModelFactory: model.vaultItemIconViewModelFactory,
      select: { select($0, .recentSearch) })
  }

  private var searchResults: some View {
    ListResultContainer(
      isSearching: $isSearching,
      sections: model.result.sections,
      vaultItemIconViewModelFactory: model.vaultItemIconViewModelFactory,
      select: { select($0, .recentSearch) }
    )
    .highlightedValue(model.searchCriteria)
  }
}

private struct InactiveSearchContainer<InactiveView: View>: View {
  @Environment(\.isSearching)
  private var searching

  @Binding
  var isSearching: Bool
  let inactiveSearchView: InactiveView

  init(
    isSearching: Binding<Bool>,
    @ViewBuilder inactiveSearchView: () -> InactiveView
  ) {
    _isSearching = isSearching
    self.inactiveSearchView = inactiveSearchView()
  }

  var body: some View {
    inactiveSearchView
      .onChange(of: searching) { _, newValue in
        self.isSearching = newValue
      }
  }
}

private struct ListResultContainer: View {
  @Environment(\.isSearching)
  private var searching

  @Environment(\.dismissSearch)
  private var dismissSearch

  @Binding
  var isSearching: Bool
  let sections: [DataSection]
  let vaultItemIconViewModelFactory: VaultItemIconViewModel.Factory
  let select: (VaultItem) -> Void

  var body: some View {
    ItemsList(sections: sections) { input in
      VaultItemRow(
        item: input.vaultItem,
        userSpace: nil,
        vaultIconViewModelFactory: vaultItemIconViewModelFactory
      )
      .onTapWithFeedback {
        dismissSearch()
        select(input.vaultItem)
      }
    }
    .onChange(of: searching) { _, newValue in
      isSearching = newValue
    }
  }
}

#Preview {
  ExtensionSearchView(
    model: .mock,
    select: { _, _ in
    },
    placeholderAccessory: {
      Text("Placeholder")
    },
    inactiveSearchView: {
      Text("Inactive")
    })
}
