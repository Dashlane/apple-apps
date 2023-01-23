import SwiftUI
import Combine
import CorePersonalData
import UIDelight
import SwiftTreats
import NotificationKit

struct HomeView: View {
    @ObservedObject
    var model: HomeViewModel

    @ObservedObject
    var searchViewModel: VaultSearchViewModel

    init(model: HomeViewModel) {
        self.model = model
        self.searchViewModel = model.vaultListViewModel.searchViewModel
    }

    @State
    private var bottomBannerHeight: CGFloat = 0

    var body: some View {
        VaultListView(
            model: model.vaultListViewModel,
            shouldHideFilters: false,
            title: L10n.Localizable.mainMenuHomePage,
            filtersFooterView: announcementsView
        )
        .padding(.bottom, bottomBannerHeight)
        .overlay(bottomBanner.onSizeChange(onBottomBannerSizeChange).hidden(searchViewModel.isSearchActive), alignment: .bottom)
        .lifeCycleEvent(onWillAppear: {
            UITableView.appearance().backgroundColor = FiberAsset.systemBackground.color
            model.modalAnnouncementsViewModel.trigger.send(.homeTabSelected)
        }, onWillDisappear: {
            UITableView.appearance().backgroundColor = FiberAsset.tableBackground.color
        })
        .searchForcedPlaceholderView(forcedPlaceholder)
                        .homeModalAnnouncements(model: model.modalAnnouncementsViewModel)
    }

        @ViewBuilder
    private var bottomBanner: some View {
        if model.shouldShowOnboardingBanner, let model = model.onboardingChecklistViewModel {
            OnboardingChecklistBanner(model: model) {
                self.model.action(.showChecklist)
            }
        } else if !Device.isIpadOrMac && model.showAutofillBanner {
            AutofillBanner(model: model.autofillBannerViewModel)
        }
    }

    @ViewBuilder
    private var announcementsView: some View {
        HomeBannersAnnouncementsView(model: model.homeAnnouncementsViewModel)
    }

    var forcedPlaceholder: ListPlaceholder? {
        guard model.shouldDisplayEmptyVaultPlaceholder else { return nil }
        let addButton = Button(action: {
                self.model.action(.addItem(displayMode: .itemType(Credential.self)))
            }, title: ItemCategory.credentials.placeholderCtaTitle)
            .eraseToAnyView()
        return ListPlaceholder(category: .credentials,
                               accessory: addButton)
    }

    private func onBottomBannerSizeChange(_ size: CGSize) {
        self.bottomBannerHeight = size.height
    }
}

extension HomeView: NavigationBarStyleProvider {
    var navigationBarStyle: NavigationBarStyle {
        .homeBarStyle
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            HomeView(model: HomeViewModel.mock)
        }
    }
}
