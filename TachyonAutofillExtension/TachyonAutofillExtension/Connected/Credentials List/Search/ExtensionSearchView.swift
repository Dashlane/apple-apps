import CoreLocalization
import DesignSystem
import SwiftUI
import UIComponents
import VaultKit

struct ExtensionSearchView<InactiveView: View>: View {
  @StateObject
  var model: ExtensionSearchViewModel

  @State
  var isSearching: Bool = false

  let select: (VaultItem, VaultSelectionOrigin) -> Void
  let inactiveSearchView: InactiveView

  init(
    model: @escaping @autoclosure () -> ExtensionSearchViewModel,
    select: @escaping (VaultItem, VaultSelectionOrigin) -> Void,
    @ViewBuilder inactiveSearchView: () -> InactiveView
  ) {
    self._model = .init(wrappedValue: model())
    self.select = select
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
    .background(.ds.background.default)
    .edgesIgnoringSafeArea(.bottom)
    .frame(maxHeight: .infinity)
    .onChange(of: isSearching) { newValue in
      model.isActive = newValue
    }
  }

  private var list: some View {
    ZStack {
      if !model.result.searchCriteria.isEmpty {
        if !model.result.hasResult() {
          ListPlaceholder(
            icon: Image(asset: FiberAsset.emptySearch),
            text: L10n.Localizable.emptySearchResultsText,
            accessory: placeholderAddButton)
        } else {
          searchResults
            .dismissKeyboardOnDrag()
            .id(model.result.searchCriteria)
        }
      } else {
        recentSearches
          .dismissKeyboardOnDrag()

      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .animation(.linear(duration: 0.2), value: model.result.searchCriteria)
  }

  private var placeholderAddButton: AnyView {
    NavigationLink(value: CredentialProviderHomeFlow.SubFlows.addCredential) {
      Text(L10n.Localizable.kwEmptyPwdAddAction)
        .foregroundColor(.ds.container.expressive.brand.catchy.idle)
    }
    .eraseToAnyView()
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
    self._isSearching = isSearching
    self.inactiveSearchView = inactiveSearchView()
  }

  var body: some View {
    inactiveSearchView
      .onChange(
        of: self.searching,
        perform: { newValue in
          self.isSearching = newValue
        })
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
    .onChange(of: searching) { newValue in
      isSearching = newValue
    }
  }
}
