import UIKit
import SwiftTreats
import DesignSystem

extension FAQItem {

    static var makeVPNGeneralItem: FAQItem {
        return .init(title: L10n.Localizable.mobileVpnPageFaqGeneralSummary,
                     description: .init(title: L10n.Localizable.mobileVpnPageFaqGeneralDetails,
                                        link: .init(label: L10n.Localizable.mobileVpnPageFaqGeneralDetailsReadMore,
                                                    url: URL(string: "_")!)))
    }

    static var makeFaqHotspotDetails: FAQItem {
        return .init(title: L10n.Localizable.mobileVpnPageFaqHotspotSummary,
                     description: .init(title: L10n.Localizable.mobileVpnPageFaqHotspotDetails))
    }

    static var makeVPNSupportItem: FAQItem {

        let faqURL = URL(string: "_")!
        let supportCenterURL = URL(string: "_")!

        let firstDescription = FAQItem.Description(title: L10n.Localizable.mobileVpnPageFaqSupportDetailsDashlaneFaq,
                                                   link: .init(label: L10n.Localizable.mobileVpnPageFaqSupportDetailsVisitDashlane,
                                                               url: faqURL))

        let secondDescription = FAQItem.Description(title: L10n.Localizable.mobileVpnPageFaqSupportDetailsHotspotSupport,
                                                    link: .init(label: L10n.Localizable.mobileVpnPageFaqSupportDetailsVisitHotspot,
                                                                url: supportCenterURL))

        return .init(title: L10n.Localizable.mobileVpnPageFaqSupportSummary,
                     descriptions: [firstDescription, secondDescription])
    }
}
