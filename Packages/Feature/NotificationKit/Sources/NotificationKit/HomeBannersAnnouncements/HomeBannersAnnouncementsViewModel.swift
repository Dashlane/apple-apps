import Foundation
import DashTypes
import Combine

public class HomeBannersAnnouncementsViewModel: ObservableObject {

    enum Banner {
        case premium
        case lastpassImport
    }

    let premiumAnnouncementsViewModel: PremiumAnnouncementsViewModel
    let autofillBannerViewModel: AutofillBannerViewModel
    let lastpassImportBannerViewModel: LastpassImportBannerViewModel
    @Published
    var showAutofillBanner: Bool = false
    let shouldShowLastpassBanner: Bool
    private let credentialsCount: Int

    private var shouldShowPremiumBannerView: Bool {
        hasPremiumAnnouncements
    }

    @Published
    var additionnalBanner: Banner?

    public init(premiumAnnouncementsViewModel: PremiumAnnouncementsViewModel,
                autofillBannerViewModel: AutofillBannerViewModel,
                lastpassImportBannerViewModel: LastpassImportBannerViewModel,
                showAutofillBannerPublisher: AnyPublisher<Bool, Never>,
                shouldShowLastpassBanner: Bool,
                credentialsCount: Int) {
        self.autofillBannerViewModel = autofillBannerViewModel
        self.shouldShowLastpassBanner = shouldShowLastpassBanner
        self.lastpassImportBannerViewModel = lastpassImportBannerViewModel
        self.credentialsCount = credentialsCount
        self.premiumAnnouncementsViewModel = premiumAnnouncementsViewModel

        premiumAnnouncementsViewModel.$announcements.map { announcements -> Banner? in
            switch (shouldShowLastpassBanner, !announcements.isEmpty, credentialsCount) {
            case (true, true, let credentialsCount):
                return credentialsCount > 5 ? .premium : .lastpassImport
            case (false, true, _):
                return .premium
            case (true, false, _):
                return .lastpassImport
            default:
                return nil
            }
        }.assign(to: &$additionnalBanner)

        showAutofillBannerPublisher.assign(to: &$showAutofillBanner)
    }

    var hasPremiumAnnouncements: Bool {
        return !premiumAnnouncementsViewModel.announcements.isEmpty
    }
}

extension HomeBannersAnnouncementsViewModel {
    static var mock: HomeBannersAnnouncementsViewModel {
        .init(premiumAnnouncementsViewModel: .mock(announcements: [.premiumExpiredAnnouncement]),
              autofillBannerViewModel: AutofillBannerViewModel.mock,
              lastpassImportBannerViewModel: .mock,
              showAutofillBannerPublisher: Just<Bool>(true).eraseToAnyPublisher(),
              shouldShowLastpassBanner: false,
              credentialsCount: 6)
    }
}
