import Foundation
import SwiftUI
import CoreSpotlight
import VaultKit

extension PasswordGeneratorView {

    static func update(_ activity: NSUserActivity) {
        activity.title = L10n.Localizable.kwCorespotlightTitlePasswordgenerator

        let set = CSSearchableItemAttributeSet.makeItem()
        set.title = L10n.Localizable.kwCorespotlightTitlePasswordgenerator
        set.contentDescription =  L10n.Localizable.kwCorespotlightDescPasswordgenerator
        set.keywords = [
            L10n.Localizable.kwCorespotlightKwdPasswordGenerator,
            L10n.Localizable.kwCorespotlightKwdRandomPassword,
            L10n.Localizable.kwCorespotlightKwdGenerateStrongPassword,
            L10n.Localizable.kwCorespotlightKwdStrongPasswords,
            L10n.Localizable.kwCorespotlightKwdNewPassword,
            L10n.Localizable.kwCorespotlightKwdPasswordSecurity
        ]
        set.url = URL(string: "_")
        activity.contentAttributeSet = set
        activity[.deeplink] = ToolDeepLinkComponent.OtherToolDeepLinkComponent.generator.rawValue
        activity.webpageURL = set.url
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        activity.isEligibleForPublicIndexing = true
    }

}
