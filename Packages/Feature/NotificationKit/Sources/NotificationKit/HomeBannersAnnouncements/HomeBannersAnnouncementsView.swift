import SwiftUI
import Combine
import SwiftTreats

public struct HomeBannersAnnouncementsView: View {
    @StateObject
    var model: HomeBannersAnnouncementsViewModel

    public init(model: @autoclosure @escaping () -> HomeBannersAnnouncementsViewModel) {
        _model = .init(wrappedValue: model())
    }

    public var body: some View {
        VStack(spacing: 0) {
            if Device.isIpad && model.showAutofillBanner {
                AutofillBanner(model: model.autofillBannerViewModel)
                if model.additionnalBanner != nil {
                    Divider()
                }
            }
            if let banner = model.additionnalBanner {
                switch banner {
                case .lastpassImport:
                    LastpassImportBanner(model: model.lastpassImportBannerViewModel)
                case .premium:
                    PremiumAnnouncementsView(model: model.premiumAnnouncementsViewModel)
                }
            }
        }
    }
}

struct HomeBannersAnnouncementsView_Previews: PreviewProvider {
    static var previews: some View {
        HomeBannersAnnouncementsView(model: .mock)
    }
}
