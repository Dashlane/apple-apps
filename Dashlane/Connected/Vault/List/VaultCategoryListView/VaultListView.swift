import SwiftUI
import UIDelight
import CorePersonalData
import DashlaneAppKit
import SwiftTreats
import CoreUserTracking
import VaultKit
import CoreLocalization

struct VaultListView<FilterFooterView: View>: View {
    @ObservedObject
    var model: VaultListViewModel

    let filtersFooterView: FilterFooterView
    let shouldHideFilters: Bool
    let title: String?

    @State
    private var bannerHeight: CGFloat = 0

    init(
        model: VaultListViewModel,
        shouldHideFilters: Bool,
        title: String?,
        filtersFooterView: FilterFooterView
    ) {
        self.model = model
        self.shouldHideFilters = shouldHideFilters
        self.filtersFooterView = filtersFooterView
        self.title = title
    }

    var body: some View {
        VaultSearchView(model: model.searchViewModel)
            .searchHeaderHeight(bannerHeight)
            .searchFiltersView(filtersView)
            .navigationTitle(title ?? model.activeFilter.category?.title ?? CoreLocalization.L10n.Core.mainMenuHomePage)
            .reportPageAppearance(model.activeFilter.page)
            .navigationBarTitleDisplayMode(Device.isIpadOrMac ? .inline : .automatic)
    }

    @ViewBuilder
    private var filtersView: some View {
        Group {
            if Device.isIpadOrMac || shouldHideFilters {
                filtersFooterView
            } else {
                VStack(spacing: 0) {
                    FiltersView(activeFilter: $model.activeFilter)
                        .padding(.top, 10)
                    filtersFooterView
                }
            }
        }.onSizeChange { size in
            bannerHeight = size.height
        }
    }
}

private extension VaultItemsSection {
    var supportIndexes: Bool {
        let categoriesWithoutIndexes: [VaultItemsSection] = [.payments, .ids, .personalInfo]
        return !categoriesWithoutIndexes.contains(self)
    }
}

struct VaultListView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            NavigationView {
                VaultListView(model: VaultListViewModel.mock, shouldHideFilters: false)
                    .navigationTitle("")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

extension VaultListView where FilterFooterView == EmptyView {
    init(model: VaultListViewModel,
         title: String? = nil,
         shouldHideFilters: Bool) {
        self.init(model: model,
                  shouldHideFilters: shouldHideFilters,
                  title: title,
                  filtersFooterView: EmptyView())
    }
}

extension VaultItemsSection {
    var page: Page {
        switch self {
        case .payments:
            return .homePayments
        case .all:
            return .homeAll
        case .credentials:
            return .homePasswords
        case .secureNotes:
            return .homeSecureNotes
        case .personalInfo:
            return .homePersonalInfo
        case .ids:
            return .homeIds
        }
    }
}
