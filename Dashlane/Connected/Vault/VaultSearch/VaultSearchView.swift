import SwiftUI
import UIKit
import DashlaneAppKit
import SwiftTreats
import Combine
import VaultKit
import DesignSystem

struct VaultSearchView: View {

    @ObservedObject
    var model: VaultSearchViewModel

    init(model: VaultSearchViewModel) {
        self.model = model
    }

    var body: some View {
        SearchView(model: model)
            .searchable(
                text: $model.searchCriteria,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: L10n.Localizable.itemsTabSearchPlaceholder
            )
            .searchActive(model.isSearchActive)
    }
}

struct VaultSearchView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VaultSearchView(model: .mock)
        }
    }
}

private struct SearchView: View {

    @Environment(\.searchFiltersView)
    private var filtersView

    @Environment(\.searchHeaderHeight)
    private var bannerHeight

    @Environment(\.searchForcedPlaceholderView)
    private var forcedPlaceholderView

    @Environment(\.isSearching)
    private var isSearching

    @ObservedObject
    var model: VaultSearchViewModel

    var body: some View {
        Group {
            if isSearching {
                list
                    .reportPageAppearance(.search)
            } else {
                emptySearchCriteriaView
            }
        }
        .frame(maxHeight: .infinity)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                UserSpaceSwitcher(model: model.userSwitcherViewModel, displayTeamName: true)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                addButton
            }
        }
        .iPhoneOnlyBackground()
        .mainMenuShortcut(.search) {
            model.isSearchActive = true
        }
        .onChange(of: isSearching) { newValue in
            model.isSearchActive = newValue
        }
    }

    private var addButton: some View {
        AddVaultButton(
            secureNoteState: model.secureNoteState,
            category: .none,
            onTap: model.onAddItemDropdown
        ) { model.add(type: $0) }
        .fiberAccessibilityLabel(Text(L10n.Localizable.accessibilityAddToVault))
        .fiberAccessibilityRemoveTraits(.isImage)
    }

    private var placeholderAddButton: AnyView {
        AddVaultButton(
            text: Text(L10n.Localizable.announceWelcomeM2DNoItemCta),
            secureNoteState: model.secureNoteState,
            category: model.activeFilter.category,
            onTap: model.onAddItemDropdown
        ) { model.add(type: $0) }
            .eraseToAnyView()
    }

    private var list: some View {
        ZStack {
            if !model.searchResult.searchCriteria.isEmpty {
                if !model.searchResult.hasResult {
                    if let category = model.activeFilter.category {
                        ListPlaceholder(category: category,
                                        accessory: placeholderAddButton)
                            .fiberAccessibilityAnnouncement(for: model.$searchResult) { _ in
                                L10n.Localizable.accessibilityVaultSearchViewNoResult
                            }
                    } else {
                        ListPlaceholder(icon: Image(asset: FiberAsset.emptySearch),
                                        text: L10n.Localizable.emptySearchResultsText,
                                        accessory: placeholderAddButton)
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
            } else {
                                recentSearches
                    .dismissKeyboardOnDrag()
                    .id(model.searchResult.searchCriteria)
                    .accessibility(label: Text(L10n.Localizable.recentSearchTitle))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.linear(duration: 0.2), value: model.searchResult.searchCriteria)
    }

    private var searchResults: some View {
        ItemsList(sections: model.searchResult.sections) { configuration in
            VaultItemRow(
                model: model.makeRowViewModel(
                    configuration.vaultItem,
                    isSuggestedItem: configuration.isSuggestedItem,
                    origin: .search
                )
            ) {
                model.select(.init(
                    item: configuration.vaultItem,
                    origin: .searchResult,
                    count: model.searchResult.count)
                )
            }
        }
        .vaultItemsListDelete(.init(model.delete))
        .vaultItemsListDeleteBehaviour(.init(model.itemDeleteBehaviour))
    }

    private var recentSearches: some View {
        ItemsList(sections: model.recentSearchSections) { configuration in
            VaultItemRow(
                model: model.makeRowViewModel(
                    configuration.vaultItem,
                    isSuggestedItem: configuration.isSuggestedItem,
                    origin: .search
                )
            ) {
                model.select(.init(
                    item: configuration.vaultItem,
                    origin: .searchResult,
                    count: model.recentSearchSections.first?.items.count ?? 0)
                )
            }
        }
    }

    @ViewBuilder
    private var inactiveSearchView: some View {
        ItemsList(sections: model.sections) { configuration in
            VaultItemRow(
                model: model.makeRowViewModel(
                    configuration.vaultItem,
                    isSuggestedItem: configuration.isSuggestedItem,
                    origin: .vault
                )
            ) {
                let origin: VaultSelectionOrigin = configuration.isSuggestedItem ? .suggestedItems : .regularList
                model.select(.init(
                    item: configuration.vaultItem,
                    origin: origin,
                    count: model.count(for: origin))
                )
            }
            .padding(.trailing, model.sections.count > 1 ? 10 : 0)
        }
        .indexed(shouldHideIndexes: !model.activeFilter.supportIndexes, priority: .indexedList)
        .vaultItemsListDelete(.init(model.delete))
        .vaultItemsListDeleteBehaviour(.init(model.itemDeleteBehaviour))
        .vaultItemsListFloatingHeader(filtersView?.eraseToAnyView())
        .overlay(placeholder, alignment: .bottom)
    }

    @ViewBuilder
    private var placeholder: some View {
        ListPlaceholder(
            vaultListFilter: model.activeFilter,
            canEditSecureNotes: !model.isSecureNoteDisabled,
            action: model.add
        )
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.systemBackground))
        .padding(.top, bannerHeight)
        .hidden(!model.sections.isEmpty)
    }

    private var emptySearchCriteriaView: AnyView {
        if let forcedPlaceholderView = forcedPlaceholderView {
            return forcedPlaceholderView
        } else {
            return inactiveSearchView.eraseToAnyView()
        }
    }
}

private extension View {
    func searchActive(_ isActive: Bool) -> some View {
        overlay(
            SearchBarIntrospectController(isActive: isActive)
                .frame(width: 0, height: 0)
        )
    }

    @ViewBuilder
    func iPhoneOnlyBackground() -> some View {
        if !Device.isIpadOrMac {
            self.background(Color.ds.background.default)
        } else {
            self
        }
    }
}

private extension VaultListFilter {
    var supportIndexes: Bool {
        return ![.payments, .ids, .personalInfo].contains(self)
    }
}

private struct SearchBarIntrospectController: UIViewControllerRepresentable {
    private var isActive: Bool

    init(isActive: Bool) {
        self.isActive = isActive
    }

    func makeUIViewController(context: Context) -> SearchBarIntrospectViewController {
        SearchBarIntrospectViewController { searchBar in
                                                if let backgroundView = searchBar?.searchTextField.subviews.first?.subviews.first {
                backgroundView.isHidden = true
            }

                        if let searchBar, let attributedPlaceholder = searchBar.searchTextField.attributedPlaceholder {
                searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
                    string: attributedPlaceholder.string,
                    attributes: [.foregroundColor: UIColor.ds.text.neutral.quiet]
                )
            }
        }
    }

    func updateUIViewController(_ viewController: SearchBarIntrospectViewController, context: Context) {
        guard viewController.searchBar?.searchTextField.isFirstResponder != isActive else { return }

        if isActive {
            DispatchQueue.main.async {
                viewController.searchBar?.searchTextField.becomeFirstResponder()
            }
        } else {
            DispatchQueue.main.async {
                viewController.searchBar?.searchTextField.resignFirstResponder()
            }
        }
    }
}

private final class SearchBarIntrospectViewController: UIViewController {
    private(set) var searchBar: UISearchBar?
    private let didMoveToParentHandler: (UISearchBar?) -> Void

    init(didMoveToParentHandler: @escaping (UISearchBar?) -> Void) {
        self.didMoveToParentHandler = didMoveToParentHandler
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)

        var parentViewController = parent
        var finishedLookup = false

                        if Device.isMac {
            repeat {
                if let navigationBar = parentViewController?.navigationController?.navigationBar {
                    searchBar = navigationBar.firstSubview(matchingType: UISearchBar.self)
                    finishedLookup = true
                } else {
                    parentViewController = parentViewController?.parent
                    finishedLookup = parentViewController == nil
                }
            } while !finishedLookup
        } else {
            repeat {
                if let searchController = parentViewController?.navigationItem.searchController {
                    searchBar = searchController.searchBar
                    finishedLookup = true
                } else {
                    parentViewController = parentViewController?.parent
                    finishedLookup = parentViewController == nil
                }
            } while !finishedLookup
        }

        didMoveToParentHandler(searchBar)
    }
}

fileprivate extension UIView {

    func firstSubview<T: UIView>(matchingType type: T.Type) -> T? {
        var subviews = self.subviews
        var finishedLookup = false

        repeat {
            guard !subviews.isEmpty else {
                finishedLookup = true
                continue
            }

            let lastSubview = subviews.removeFirst()

            if let subview = lastSubview as? T {
                return subview
            } else {
                subviews.append(contentsOf: lastSubview.subviews)
            }

        } while !finishedLookup

        return nil
    }
}

extension ItemsList {
            @ViewBuilder
    func indexed(shouldHideIndexes: Bool = false, priority: HomeListElementPriority) -> some View {
        self.indexed(shouldHideIndexes: shouldHideIndexes, accessibilityPriority: priority.rawValue)
    }
}
