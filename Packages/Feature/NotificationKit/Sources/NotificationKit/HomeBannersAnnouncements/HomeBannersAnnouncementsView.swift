import SwiftUI
import Combine
import SwiftTreats

public struct HomeBannersAnnouncementsView: View {
    var model: HomeBannersAnnouncementsViewModel

    public init(model: HomeBannersAnnouncementsViewModel) {
        self.model = model
    }

    public var body: some View {
        VStack(spacing: 0) {
            if Device.isIpad && model.showAutofillBanner {
                AutofillBanner(model: model.autofillBannerViewModel)
                if model.hasPremiumAnnouncements {
                    Divider()
                }
            }
            if let premiumAnnouncements = model.premiumAnnouncementsViewModel {
                PremiumAnnouncementsView(model: premiumAnnouncements)
            }
        }
        .hidden(shouldHideAnnouncements)
    }

    private var shouldHideAnnouncements: Bool {
        !model.hasPremiumAnnouncements && !model.showAutofillBanner
    }
}


struct HomeBannersAnnouncementsView_Previews: PreviewProvider {
    static let model = HomeBannersAnnouncementsViewModel(autofillBannerViewModel: AutofillBannerViewModel.mock,
                                                  showAutofillBanner: true)
    static var previews: some View {
        HomeBannersAnnouncementsView(model: model)
    }
}
