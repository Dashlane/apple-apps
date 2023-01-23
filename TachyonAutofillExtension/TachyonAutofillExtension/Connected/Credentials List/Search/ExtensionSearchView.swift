import SwiftUI
import DashlaneAppKit
import UIComponents
import VaultKit

struct ExtensionSearchView<InactiveView: View, Model: ExtensionSearchViewModelProtocol>: View {

    @ObservedObject
    var model: Model

    let select: (VaultItem, VaultSelectionOrigin) -> Void
    let inactiveSearchView: InactiveView

    let addAction: () -> Void
    let closeAction: () -> Void
    let onSearchAppear: () -> Void
    
    init(model: Model,
         addAction: @escaping () -> Void,
         closeAction: @escaping () -> Void,
         select: @escaping (VaultItem, VaultSelectionOrigin) -> Void,
         onSearchAppear: @escaping () -> Void,
         @ViewBuilder inactiveSearchView: () -> InactiveView) {
        self.model = model
        self.closeAction = closeAction
        self.addAction = addAction
        self.select = select
        self.inactiveSearchView = inactiveSearchView()
        self.onSearchAppear = onSearchAppear
    }
    
    var body: some View {
        SearchView(model: model,
                   select: select,
                   inactiveSearchView: inactiveSearchView,
                   addAction: addAction,
                   closeAction: closeAction,
                   onSearchAppear: onSearchAppear)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationBarButton(action: closeAction, title: L10n.Localizable.cancel)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                AddBarButton(style: .circle, action: addAction)
            }
        }
        .searchable(text: $model.searchCriteria, prompt: L10n.Localizable.tachyonCredentialsListSearchPlaceholder)
        .background(Color(asset: FiberAsset.systemBackground))
        .edgesIgnoringSafeArea(.bottom)
    }

    private var addButton: some View {
        AddBarButton(style: .circle, action: addAction)
    }
}

private struct SearchView<InactiveView: View, Model: ExtensionSearchViewModelProtocol>: View {

    @Environment(\.isSearching)
    private var isSearching

    @Environment(\.dismissSearch)
    private var dismissSearch

    @ObservedObject
    var model: Model

    let select: (VaultItem, VaultSelectionOrigin) -> Void
    let inactiveSearchView: InactiveView

    let addAction: () -> Void
    let closeAction: () -> Void
    let onSearchAppear: () -> Void

    var body: some View {
        Group {
            if isSearching {
                list
                    .navigationBarBackButtonHidden(true)
                    .onAppear(perform: onSearchAppear)
            } else {
                inactiveSearchView
            }
        }
        .frame(maxHeight: .infinity)
        .onChange(of: isSearching) { newValue in
            model.isActive = newValue
        }
    }

    private var list: some View {
        ZStack {
            if !model.result.searchCriteria.isEmpty {
                if !model.result.hasResult {
                    ListPlaceholder(icon: Image(asset: FiberAsset.emptySearch),
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
        return Button(action: addAction, title: L10n.Localizable.kwEmptyPwdAddAction)
            .foregroundColor(.ds.container.expressive.brand.catchy.idle)
                .eraseToAnyView()
    }

    private var recentSearches: some View {
        ItemsList(sections: model.recentSearchItems) { input in
            CredentialRowView(model: CredentialRowViewModel(item: input.vaultItem,
                                                            domainLibrary: model.domainIconLibrary,
                                                            highlightedString: model.searchCriteria)) {
                dismissSearch()
                select(input.vaultItem, .recentSearch)
            }
        }
    }

    private var searchResults: some View {
        ItemsList(sections: model.result.sections) { input in
            CredentialRowView(model: CredentialRowViewModel(item: input.vaultItem,
                                                            domainLibrary: model.domainIconLibrary,
                                                            highlightedString: model.searchCriteria)) {
                dismissSearch()
                self.select(input.vaultItem, .searchResult)
            }
        }
    }
}

