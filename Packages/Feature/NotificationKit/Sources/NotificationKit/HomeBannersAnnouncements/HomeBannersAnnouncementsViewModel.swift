import Foundation
import DashTypes

public struct HomeBannersAnnouncementsViewModel {

    let premiumAnnouncementsViewModel: PremiumAnnouncementsViewModel?
    let autofillBannerViewModel: AutofillBannerViewModel
    var showAutofillBanner: Bool

    public init(premiumAnnouncementsViewModel: PremiumAnnouncementsViewModel? = nil,
                autofillBannerViewModel: AutofillBannerViewModel,
                showAutofillBanner: Bool) {
        self.showAutofillBanner = showAutofillBanner
        self.autofillBannerViewModel = autofillBannerViewModel
        self.premiumAnnouncementsViewModel = premiumAnnouncementsViewModel
    }

    var hasPremiumAnnouncements: Bool {
        guard let premiumAnnouncementsViewModel else { return false }
        return !premiumAnnouncementsViewModel.announcements.isEmpty
    }
}

extension HomeBannersAnnouncementsViewModel {
    static var mock: HomeBannersAnnouncementsViewModel {
        .init(autofillBannerViewModel: AutofillBannerViewModel.mock,
              showAutofillBanner: true)
    }
}
