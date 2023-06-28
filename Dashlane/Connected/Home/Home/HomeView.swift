import Combine
import CorePersonalData
import NotificationKit
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight
import VaultKit
import CoreLocalization

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
            title: CoreLocalization.L10n.Core.mainMenuHomePage,
            filtersFooterView: announcementsView
        )
        .padding(.bottom, bottomBannerHeight)
        .overlay(bottomBanner.onSizeChange(onBottomBannerSizeChange).hidden(searchViewModel.isSearchActive), alignment: .bottom)
        .lifeCycleEvent(onWillAppear: {
            UITableView.appearance().backgroundColor = UIColor.ds.background.default
        }, onWillDisappear: {
            UITableView.appearance().backgroundColor = UIColor.ds.background.default
        })
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
        HomeBannersAnnouncementsView(model: model.makeHomeAnnouncementsViewModel())
    }

    private func onBottomBannerSizeChange(_ size: CGSize) {
        self.bottomBannerHeight = size.height
    }
}

extension HomeView: NavigationBarStyleProvider {
    var navigationBarStyle: UIComponents.NavigationBarStyle {
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
